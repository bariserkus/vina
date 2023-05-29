/*

   Copyright (c) 2006-2010, The Scripps Research Institute

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.

   Author: Dr. Oleg Trott <ot14@columbia.edu>, 
           The Olson Lab, 
           The Scripps Research Institute

*/

#ifndef VINA_BFGS_H
#define VINA_BFGS_H

#include "matrix.h"

typedef triangular_matrix<fl> flmat;

template<typename Change>
void minus_mat_vec_product(const flmat& m, const Change& in, Change& out, const int gvl) {
    sz n = m.dim();
    for (int i = 0; i < n; i += gvl) {
        __epi_1xf64 v_sum = __builtin_epi_vbrdcast_1xf64(0.0, gvl);
        for (int j = 0; j < gvl; ++j) {
            __epi_1xf64 v_m = __builtin_epi_vload_1xf64(&m(i, j), gvl);
            __epi_1xf64 v_in = __builtin_epi_vload_1xf64(&in(j), gvl);
            v_sum = __builtin_epi_vfmacc_1xf64(v_m, v_in, v_sum, gvl);
        }
        __builtin_epi_vstore_1xf64(&out(i), __builtin_epi_vneg_1xf64(v_sum, gvl), gvl);
    }
}

template<typename Change>
inline fl scalar_product(const Change& a, const Change& b, sz n, const int gvl) {
    fl tmp = 0;
    for (int i = 0; i < n; i += gvl) {
        __epi_1xf64 v_tmp = __builtin_epi_vbrdcast_1xf64(0.0, gvl);
        for (int j = 0; j < gvl; ++j) {
            __epi_1xf64 v_a = __builtin_epi_vload_1xf64(&a(i + j), gvl);
            __epi_1xf64 v_b = __builtin_epi_vload_1xf64(&b(i + j), gvl);
            v_tmp = __builtin_epi_vfmacc_1xf64(v_a, v_b, v_tmp, gvl);
        }
        tmp += __builtin_epi_vreduce_1xf64(v_tmp, gvl);
    }
    return tmp;
}

template<typename Change>
inline bool bfgs_update(flmat& h, const Change& p, const Change& y, const fl alpha, const int gvl) {
    const fl yp = scalar_product(y, p, h.dim(), gvl);
    if (alpha * yp < epsilon_fl) return false;

    Change minus_hy(y);
    minus_mat_vec_product(h, y, minus_hy, gvl);

    const fl yhy = -scalar_product(y, minus_hy, h.dim(), gvl);
    const fl r = 1 / (alpha * yp);

    const sz n = p.num_floats();
    for (int i = 0; i < n; i += gvl) {
        __epi_1xf64 v_r = __builtin_epi_vbrdcast_1xf64(r, gvl);
        for (int j = i; j < n; j += gvl) {
            __epi_1xf64 v_minus_hy = __builtin_epi_vload_1xf64(&minus_hy(j), gvl);
            __epi_1xf64 v_p = __builtin_epi_vload_1xf64(&p(i), gvl);
            __epi_1xf64 v_p_transpose = __builtin_epi_vbrdcast_1xf64(p(j), gvl);
            __epi_1xf64 v_h = __builtin_epi_vload_1xf64(&h(i, j), gvl);
            __epi_1xf64 v_h_update = __builtin_epi_vfmacc_1xf64(v_minus_hy, v_p, v_h, gvl);
            v_h_update = __builtin_epi_vfmacc_1xf64(v_minus_hy, v_p_transpose, v_h_update, gvl);
            v_h_update = __builtin_epi_vfmacc_1xf64(v_p, v_p_transpose, v_h_update, gvl);
            v_h_update = __builtin_epi_vfmacc_1xf64(v_h_update, __builtin_epi_vfmacc_1xf64(v_r, v_r, v_r, gvl), __builtin_epi_vbrdcast_1xf64(yhy, gvl), gvl);
            __builtin_epi_vstore_1xf64(&h(i, j), v_h_update, gvl);
        }
    }
    return true;
}

template<typename F, typename Conf, typename Change>
fl line_search(F& f, sz n, const Conf& x, const Change& g, const fl f0, const Change& p, Conf& x_new, Change& g_new, fl& f1, int& evalcount) {
    const fl c0 = 0.0001;
    const unsigned max_trials = 10;
    const fl multiplier = 0.5;
    fl alpha = 1;

    const fl pg = scalar_product(p, g, n, 1); // Scalar product, so gvl = 1

    VINA_U_FOR(trial, max_trials) {
        x_new = x;
        x_new.increment(p, alpha);
        f1 = f(x_new, g_new);
        evalcount++;
        if (f1 - f0 < c0 * alpha * pg)
            break;
        alpha *= multiplier;
    }
    return alpha;
}

inline void set_diagonal(flmat& m, fl x, const int gvl) {
    sz n = m.dim();
    for (int i = 0; i < n; ++i) {
        m(i, i) = x;
    }
}

template<typename Change>
void subtract_change(Change& b, const Change& a, sz n, const int gvl) {
    for (int i = 0; i < n; ++i)
        b(i) -= a(i);
}

template<typename F, typename Conf, typename Change>
fl bfgs(F& f, Conf& x, Change& g, const unsigned max_steps, const fl average_required_improvement, const sz over,
        int& evalcount) {
    sz n = g.num_floats();
    flmat h(n, 0);
    set_diagonal(h, 1, 1); // Scalar value, so gvl = 1

    Change g_new(g);
    Conf x_new(x);
    fl f0 = f(x, g);
    evalcount++;

    fl f_orig = f0;
    Change g_orig(g);
    Conf x_orig(x);

    Change p(g);

    flv f_values;
    f_values.reserve(max_steps + 1);
    f_values.push_back(f0);

    VINA_U_FOR(step, max_steps) {
        minus_mat_vec_product(h, g, p, 1); // Scalar product, so gvl = 1
        fl f1 = 0;
        const fl alpha = line_search(f, n, x, g, f0, p, x_new, g_new, f1, evalcount);
        Change y(g_new);
        subtract_change(y, g, n, 1); // Scalar product, so gvl = 1

        f_values.push_back(f1);
        f0 = f1;
        x = x_new;
        if (!(std::sqrt(scalar_product(g, g, n, 1)) >= 1e-5))
            break;

        g = g_new;

        if (step == 0) {
            const fl yy = scalar_product(y, y, n, 1); // Scalar product, so gvl = 1
            if (std::abs(yy) > epsilon_fl)
                set_diagonal(h, alpha * scalar_product(y, p, n, 1) / yy, 1); // Scalar values, so gvl = 1
        }

        bool h_updated = bfgs_update(h, p, y, alpha, 1); // Scalar product, so gvl = 1
    }

    if (!(f0 <= f_orig)) {
        f0 = f_orig;
        x = x_orig;
        g = g_orig;
    }

    return f0;
}

#endif

#endif
