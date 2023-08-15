from numpy.linalg import (
    det,
    eig,
    inv,
    matrix_power as mp,
    multi_dot,
    norm,
)
from scipy.linalg import expm
from numpy import transpose as t
import numpy as np


def M(s):
    return np.array(np.mat(s.strip().replace('\n', ';')))


def dot(*args):
    return multi_dot(args)


def svd(A):
    U, S_diag, Vt = np.linalg.svd(A, full_matrices=True)
    U_n, S_n = U.shape[1], S_diag.shape[0]
    S_matrix = np.zeros((U_n, S_n))
    S_matrix[:S_n, :S_n] = np.diag(S_diag)
    assert np.allclose(A, dot(U, S_matrix, Vt)), 'invalid SVD!'
    return U, S_matrix, Vt


def rsvd(A):
    U, S_diag, Vt = np.linalg.svd(A, full_matrices=False)
    S_matrix = np.diag(S_diag)
    assert np.allclose(A, dot(U, S_matrix, Vt)), 'invalid SVD!'
    return U, S_matrix, Vt
