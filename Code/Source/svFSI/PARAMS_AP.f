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
!--------------------------------------------------------------------
!
!     Parameters used for Aliev-Panfilov Ventricular Myocyte Model.
!
!--------------------------------------------------------------------

!     Scaling factors
!     Voltage scaling
      REAL(KIND=RKIND) :: Vscale  = 100._RKIND
!     Time scaling
      REAL(KIND=RKIND) :: Tscale  = 12.9_RKIND
!     Voltage offset parameter
      REAL(KIND=RKIND) :: Voffset = -80._RKIND
!-----------------------------------------------------------------------
!     Model parameters
      REAL(KIND=RKIND) :: alpha = 1.E-2_RKIND
      REAL(KIND=RKIND) :: a     = 2.E-3_RKIND
      REAL(KIND=RKIND) :: b     = 0.15_RKIND
      REAL(KIND=RKIND) :: c     = 8._RKIND
      REAL(KIND=RKIND) :: mu1   = 0.2_RKIND
      REAL(KIND=RKIND) :: mu2   = 0.3_RKIND
!-----------------------------------------------------------------------
!     Electromechanics coupling parameters: active stress model
!     Resting voltage (mV)
      REAL(KIND=RKIND) :: Vrest = -80._RKIND
!     Critical voltage (mV)
      REAL(KIND=RKIND) :: Vcrit = -30._RKIND
!     Saturation potential
      REAL(KIND=RKIND) :: eta_T = 5.E-3_RKIND
!     Minimum activation (ms^{-1})
      REAL(KIND=RKIND) :: eps_0 = 0.1_RKIND
!     Maximum activation (ms^{-1})
      REAL(KIND=RKIND) :: eps_i = 1._RKIND
!     Transition rate (mV^{-1})
      REAL(KIND=RKIND) :: xi_T  = 1._RKIND

!     Cm: Cell capacitance per unit surface area
      REAL(KIND=RKIND) :: Cm  = 1._RKIND
!     sV: Surface to volume ratio
      REAL(KIND=RKIND) :: sV  = 1._RKIND
!     rho: Cellular resistivity
      REAL(KIND=RKIND) :: rho = 1._RKIND
!#######################################################################
