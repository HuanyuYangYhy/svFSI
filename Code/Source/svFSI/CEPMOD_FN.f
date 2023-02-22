!
! Copyright (c) Stanford University, The Regents of the University of
!               California, and others.
!
! All Rights Reserved.
!
! See Copyright-SimVascular.txt for additional details.
!
! Permission is hereby granted, free of charge, to any person obtaining
! a copy of this software and associated documentation files (the
! "Software"), to deal in the Software without restriction, including
! without limitation the rights to use, copy, modify, merge, publish,
! distribute, sublicense, and/or sell copies of the Software, and to
! permit persons to whom the Software is furnished to do so, subject
! to the following conditions:
!
! The above copyright notice and this permission notice shall be included
! in all copies or substantial portions of the Software.
!
! THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
! IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
! TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
! PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
! OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
! EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
! PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
! LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
! NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
! SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!
!-----------------------------------------------------------------------
!
!     This module defines data structures for Fitzhugh-Nagumo cellular
!     activation model for cardiac electrophysiology.
!
!-----------------------------------------------------------------------

      MODULE FNMOD
      USE TYPEMOD
      IMPLICIT NONE

      INTERFACE FN_INIT
         MODULE PROCEDURE :: FN_INIT0, FN_INITS, FN_INITV
      END INTERFACE FN_INIT

      CONTAINS
!-----------------------------------------------------------------------
      SUBROUTINE FN_INIT0(nX, X)
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: nX
      REAL(KIND=RKIND), INTENT(INOUT) :: X(nX)

      X(:) = 1.E-3_RKIND

      RETURN
      END SUBROUTINE FN_INIT0
!-----------------------------------------------------------------------
      SUBROUTINE FN_INITS(nX, X, X0)
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: nX
      REAL(KIND=RKIND), INTENT(INOUT) :: X(nX)
      REAL(KIND=RKIND), INTENT(IN) :: X0

      X(:) = X0

      RETURN
      END SUBROUTINE FN_INITS
!-----------------------------------------------------------------------
      SUBROUTINE FN_INITV(nX, X, X0)
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: nX
      REAL(KIND=RKIND), INTENT(INOUT) :: X(nX)
      REAL(KIND=RKIND), INTENT(IN) :: X0(:)

      IF (SIZE(X0,1) .NE. nX) THEN
         STOP "ERROR: inconsistent array size (AP initialization)"
      END IF
      X(:) = X0(:)

      RETURN
      END SUBROUTINE FN_INITV
!-----------------------------------------------------------------------
!     Time integration performed using Forward Euler method
      SUBROUTINE FN_INTEGFE(nX, X, Ts, Ti, Istim)
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: nX
      REAL(KIND=RKIND), INTENT(INOUT) :: X(nX)
      REAL(KIND=RKIND), INTENT(IN) :: Ts, Ti, Istim

      INCLUDE "PARAMS_FN.f"

      REAL(KIND=RKIND) :: t, dt, f(nX), fext

      t    = Ts / Tscale
      dt   = Ti / Tscale
      fext = Istim * Tscale / Vscale

      X(1) = (X(1) - Voffset)/Vscale
      CALL FN_GETF(nX, X, f, fext)
      X(:) = X(:) + dt*f(:)
      X(1) = X(1)*Vscale + Voffset

      RETURN
      END SUBROUTINE FN_INTEGFE
!-----------------------------------------------------------------------
!     Time integration performed using 4th order Runge-Kutta method
      SUBROUTINE FN_INTEGRK(nX, X, Ts, Ti, Istim)
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: nX
      REAL(KIND=RKIND), INTENT(INOUT) :: X(nX)
      REAL(KIND=RKIND), INTENT(IN) :: Ts, Ti, Istim

      INCLUDE "PARAMS_FN.f"

      REAL(KIND=RKIND) :: t, dt, dt6, fext, Xrk(nX), frk(nX,4)

      t    = Ts / Tscale
      dt   = Ti / Tscale
      dt6  = dt / 6._RKIND

      fext = Istim * Tscale / Vscale
      X(1) = (X(1) - Voffset)/Vscale

!     RK4: 1st pass
      Xrk  = X
      CALL FN_GETF(nX, Xrk, frk(:,1), fext)

!     RK4: 2nd pass
      Xrk  = X + 0.5_RKIND*dt*frk(:,1)
      CALL FN_GETF(nX, Xrk, frk(:,2), fext)

!     RK4: 3rd pass
      Xrk  = X + 0.5_RKIND*dt*frk(:,2)
      CALL FN_GETF(nX, Xrk, frk(:,3), fext)

!     RK4: 4th pass
      Xrk  = X + dt*frk(:,3)
      CALL FN_GETF(nX, Xrk, frk(:,4), fext)

      X = X + dt6*(frk(:,1) + 2._RKIND*(frk(:,2) + frk(:,3)) + frk(:,4))

      X(1) = X(1)*Vscale + Voffset

      RETURN
      END SUBROUTINE FN_INTEGRK
!-----------------------------------------------------------------------
!     Time integration performed using Crank-Nicholson method
      SUBROUTINE FN_INTEGCN2(nX, Xn, Ts, Ti, Istim, IPAR, RPAR)
      USE MATFUN
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: nX
      INTEGER(KIND=IKIND), INTENT(INOUT) :: IPAR(2)
      REAL(KIND=RKIND), INTENT(INOUT) :: Xn(nX), RPAR(2)
      REAL(KIND=RKIND), INTENT(IN) :: Ts, Ti, Istim

      INCLUDE "PARAMS_FN.f"

      REAL(KIND=RKIND), PARAMETER :: eps = EPSILON(eps)

      INTEGER(KIND=IKIND) :: i, k, itMax
      LOGICAL :: l1, l2, l3
      REAL(KIND=RKIND) :: t, dt, fext, atol, rtol, Xk(nX), fn(nX),
     2   fK(nX), rK(nX), Im(nX,nX), JAC(nX,nX), rmsA, rmsR

      itMax = IPAR(1)
      atol  = RPAR(1)
      rtol  = RPAR(2)

      t     = Ts / Tscale
      dt    = Ti / Tscale
      fext  = Istim * Tscale / Vscale
      Xn(1) = (Xn(1) - Voffset)/Vscale
      Im    = MAT_ID(nX)

      CALL FN_GETF(nX, Xn, fn, fext)

      k  = 0
      Xk = Xn
      l1 = .FALSE.
      l2 = .FALSE.
      l3 = .FALSE.
      t  = Ts + dt
      DO
         k = k + 1
         CALL FN_GETF(nX, Xk, fk, fext)
         rK(:) = Xk(:) - Xn(:) - 0.5_RKIND*dt*(fk(:) + fn(:))

         rmsA = 0._RKIND
         rmsR = 0._RKIND
         DO i=1, nX
            rmsA = rmsA + rK(i)**2._RKIND
            rmsR = rmsR + ( rK(i) / (Xk(i)+eps) )**2._RKIND
         END DO
         rmsA = SQRT(rmsA/REAL(nX, KIND=RKIND))
         rmsR = SQRT(rmsR/REAL(nX, KIND=RKIND))

         l1   = k .GT. itMax
         l2   = rmsA .LE. atol
         l3   = rmsR .LE. rtol
         IF (l1 .OR. l2 .OR. l3) EXIT

         CALL FN_GETJ(nX, Xk, JAC)
         JAC   = Im - 0.5_RKIND*dt*JAC
         JAC   = MAT_INV(JAC, nX)
         rK(:) = MATMUL(JAC, rK)
         Xk(:) = Xk(:) - rK(:)
      END DO
      Xn(:) = Xk(:)
      CALL FN_GETF(nX, Xn, fn, fext)
      Xn(1) = Xn(1)*Vscale + Voffset

      IF (.NOT.l2 .AND. .NOT.l3) IPAR(2) = IPAR(2) + 1

      RETURN
      END SUBROUTINE FN_INTEGCN2
!-----------------------------------------------------------------------
      SUBROUTINE FN_GETF(n, X, f, fext)
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: n
      REAL(KIND=RKIND), INTENT(IN) :: X(n), fext
      REAL(KIND=RKIND), INTENT(OUT) :: f(n)

      INCLUDE "PARAMS_FN.f"

      f(1) = c * ( X(1)*(X(1)-alpha)*(1._RKIND-X(1)) - X(2) ) + fext

      f(2) = X(1) - b*X(2) + a

      RETURN
      END SUBROUTINE FN_GETF
!-----------------------------------------------------------------------
      SUBROUTINE FN_GETJ(n, X, JAC)
      IMPLICIT NONE
      INTEGER(KIND=IKIND), INTENT(IN) :: n
      REAL(KIND=RKIND), INTENT(IN) :: X(n)
      REAL(KIND=RKIND), INTENT(OUT) :: JAC(n,n)

      INCLUDE "PARAMS_FN.f"

      REAL(KIND=RKIND) :: n1, n2

      n1 = -3._RKIND*X(1)**2._RKIND
      n2 = 2._RKIND*(1._RKIND+alpha)*X(1)
      JAC(1,1) = c * (n1 + n2 - 1._RKIND)
      JAC(1,2) = -c
      JAC(2,1) = 1._RKIND
      JAC(2,2) = -b

      RETURN
      END SUBROUTINE FN_GETJ
!-----------------------------------------------------------------------
      END MODULE FNMOD
!#######################################################################

