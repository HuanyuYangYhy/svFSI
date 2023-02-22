!--------------------------------------------------------------------
!     Created by Mahdi Esmaily Moghadam
!     contact memt63@gmail.com for reporting the bugs.
!--------------------------------------------------------------------
!
!     UC Copyright Notice
!     This software is Copyright ©2012 The Regents of the University of
!     California. All Rights Reserved.
!
!     Permission to copy and modify this software and its documentation
!     for educational, research and non-profit purposes, without fee,
!     and without a written agreement is hereby granted, provided that
!     the above copyright notice, this paragraph and the following three
!     paragraphs appear in all copies.
!
!     Permission to make commercial use of this software may be obtained
!     by contacting:
!     Technology Transfer Office
!     9500 Gilman Drive, Mail Code 0910
!     University of California
!     La Jolla, CA 92093-0910
!     (858) 534-5815
!     invent@ucsd.edu
!
!     This software program and documentation are copyrighted by The
!     Regents of the University of California. The software program and
!     documentation are supplied "as is", without any accompanying
!     services from The Regents. The Regents does not warrant that the
!     operation of the program will be uninterrupted or error-free. The
!     end-user understands that the program was developed for research
!     purposes and is advised not to rely exclusively on the program for
!     any reason.
!
!     IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY
!     PARTY FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL
!     DAMAGES, INCLUDING LOST PROFITS, ARISING OUT OF THE USE OF THIS
!     SOFTWARE AND ITS DOCUMENTATION, EVEN IF THE UNIVERSITY OF
!     CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!     THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY
!     WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
!     OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
!     SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE
!     UNIVERSITY OF CALIFORNIA HAS NO OBLIGATIONS TO PROVIDE
!     MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS.
!
!--------------------------------------------------------------------

      SUBROUTINE PCGMRES(lhs, ls, dof, Val, R)
      INCLUDE "FSILS_STD.h"
      TYPE(FSILS_lhsType), INTENT(INOUT) :: lhs
      TYPE(FSILS_lsType), INTENT(INOUT) :: ls
      INTEGER(KIND=LSIP), INTENT(IN) :: dof
      REAL(KIND=LSRP), INTENT(IN) :: Val(dof*dof,lhs%nnz)
      REAL(KIND=LSRP), INTENT(INOUT) :: R(dof,lhs%nNo)

      LOGICAL flag
      INTEGER(KIND=LSIP) nNo, mynNo, i, j, k, l, nsd, sD
      REAL(KIND=LSRP) FSILS_CPUT, FSILS_NORMV, FSILS_DOTV, FSILS_NCDOTV
      REAL(KIND=LSRP) eps, tmp

      REAL(KIND=LSRP), ALLOCATABLE :: u(:,:,:), h(:,:), X(:,:), y(:),   &
     &   c(:), s(:), err(:), Ua(:,:)
      REAL(KIND=LSRP), ALLOCATABLE :: mK(:,:), mG(:,:), mD(:,:), mL(:), &
     &   Gt(:,:), Xm(:,:), Xc(:), Um(:,:), Uc(:)

      nsd = dof - 1
      flag = .FALSE.
      nNo = lhs%nNo
      mynNo = lhs%mynNo
      sD = ls%GM%sD

      ALLOCATE(Xm(nsd,nNo), Xc(nNo), Um(nsd,nNo), Uc(nNo))
      ALLOCATE(h(sD+1,sD), u(dof,nNo,sD+1), X(dof,nNo),
     &   y(sD), c(sD), s(sD), err(sD+1), Ua(dof,nNo))

      ls%RI%callD  = FSILS_CPUT()
      ls%RI%suc    = .FALSE.
      eps       = FSILS_NORMV(dof, mynNo, lhs%commu, R)
      ls%RI%iNorm  = eps
      ls%RI%fNorm  = eps
      eps       = MAX(ls%RI%absTol,ls%RI%relTol*eps)
      ls%RI%itr    = 0
      X         = 0._LSRP

      CALL DEPART
      CALL BCPRE

      IF (ls%RI%iNorm .LE. ls%RI%absTol) THEN
         ls%RI%callD = EPSILON(ls%RI%callD)
         ls%RI%dB    = 0._LSRP
         RETURN
      END IF

      IF (ANY(lhs%face%coupledFlag).AND.flag) THEN
         Ua = R
         CALL ADDBCMUL(lhs, BCOP_TYPE_PRE, dof, Ua, R)
      END IF

      DO l=1, ls%RI%mItr
         ls%RI%dB = ls%RI%fNorm
         ls%RI%itr = ls%RI%itr + 1
         CALL DOMUL(X, u(:,:,1), .false.)

         u(:,:,1) = R - u(:,:,1)
         err(1)   = FSILS_NORMV(dof, mynNo, lhs%commu, u(:,:,1))
         u(:,:,1) = u(:,:,1)/err(1)
         DO i=1, sD
            ls%RI%itr = ls%RI%itr + 1
            CALL DOMUL(u(:,:,i),u(:,:,i+1),.false.)

            DO j=1, i+1
               h(j,i) = FSILS_NCDOTV(dof, mynno, u(:,:,j), u(:,:,i+1))
            END DO
            CALL FSILS_BCASTV(i+1, h(:,i), lhs%commu)

            DO j=1, i
               CALL OMPSUMV(dof, nNo, -h(j,i), u(:,:,i+1), u(:,:,j))
!              u(:,:,i+1) = u(:,:,i+1) - h(j,i)*u(:,:,j)
               h(i+1,i) = h(i+1,i) - h(j,i)*h(j,i)
            END DO
            h(i+1,i) = SQRT(ABS(h(i+1,i)))

            CALL OMPMULV(dof, nNo, 1._LSRP/h(i+1,i), u(:,:,i+1))
            !u(:,:,i+1) = u(:,:,i+1)/h(i+1,i)
            DO j=1, i-1
               tmp      =  c(j)*h(j,i) + s(j)*h(j+1,i)
               h(j+1,i) = -s(j)*h(j,i) + c(j)*h(j+1,i)
               h(j,i)   =  tmp
            END DO
            tmp      = SQRT(h(i,i)*h(i,i) + h(i+1,i)*h(i+1,i))
            c(i)     = h(i,i)/tmp
            s(i)     = h(i+1,i)/tmp
            h(i,i)   = tmp
            h(i+1,i) = 0._LSRP
            err(i+1) = -s(i)*err(i)
            err(i)   =  c(i)*err(i)
            IF (ABS(err(i+1)) .LT. eps) THEN
               ls%RI%suc = .TRUE.
               EXIT
            END IF
         END DO
         IF (i .GT. sD) i =sD

         y = err(1:i)
         DO j=i, 1, -1
            DO k=j+1, i
               y(j) = y(j) - h(j,k)*y(k)
            END DO
            y(j) = y(j)/h(j,j)
         END DO

         DO j=1, i
            CALL OMPSUMV(dof, nNo, y(j), X, u(:,:,j))
            !X = X + u(:,:,j)*y(j)
         END DO
         ls%RI%fNorm = ABS(err(i+1))
         IF (ls%RI%suc) EXIT
      END DO
      CALL DOMUL(X,R,.true.)
      ls%RI%callD = FSILS_CPUT() - ls%RI%callD
      ls%RI%dB    = 10._LSRP*LOG(ls%RI%fNorm/ls%RI%dB)

      RETURN
      CONTAINS
!--------------------------------------------------------------------
      SUBROUTINE DOMUL(X, R, flag)
      IMPLICIT NONE
      REAL(KIND=LSRP), INTENT(IN) :: X(dof,lhs%nNo)
      REAL(KIND=LSRP), INTENT(INOUT) :: R(dof,lhs%nNo)
      LOGICAL, INTENT(IN) :: flag

      if (.true.) then
      Xm = X(1:nsd,:)
      Xc = X(dof,:)
!     Um = K^-1*Xm
      CALL GMRES(lhs, ls%GM, nsd, mK, Xm, Um)
!     Uc = D*Um
      CALL FSILS_SPARMULVS(lhs, lhs%rowPtr, lhs%colPtr, nsd, mD, Um, Uc)
!     Uc = Xc - Uc
      Uc = Xc - Uc
!     Uc = [L + G^t*G]^-1*Uc
      CALL CGRAD_SCHUR(lhs, ls%CG, nsd, Gt, mG, mL, Uc)
!     Um = G*Uc
      CALL FSILS_SPARMULSV(lhs, lhs%rowPtr, lhs%colPtr, nsd, mG, Uc, Um)
!     Xm = Xm - Um
      Xm = Xm - Um
!     Um = K^-1*Xm
      CALL GMRES(lhs, ls%GM, nsd, mK, Xm, Um)

      IF (flag) THEN
         R(1:nsd,:) = Um
         R(dof,:)   = Uc
         RETURN
      END IF

      Ua(1:nsd,:) = Um
      Ua(dof,:)   = Uc
      else
         if (flag) then
            r=x
            return
         end if
         ua = x
      end if

      CALL FSILS_SPARMULVV(lhs, lhs%rowPtr, lhs%colPtr, dof, Val, Ua, R)
      CALL ADDBCMUL(lhs, BCOP_TYPE_ADD, dof, Ua, R)

      IF (ANY(lhs%face%coupledFlag).AND.flag) THEN
         Ua = R
         CALL ADDBCMUL(lhs,BCOP_TYPE_PRE,dof, Ua, R)
      END IF

      RETURN
      END SUBROUTINE DOMUL
!--------------------------------------------------------------------
      SUBROUTINE BCPRE
      IMPLICIT NONE

      INTEGER(KIND=LSIP) faIn, i, a, Ac, nsd
      REAL(KIND=LSRP) FSILS_NORMV

      REAL(KIND=LSRP), ALLOCATABLE :: v(:,:)

      nsd = dof -  1
      ALLOCATE(v(nsd,nNo))
      DO faIn=1, lhs%nFaces
         IF (lhs%face(faIn)%coupledFlag) THEN
            IF (lhs%face(faIn)%sharedFlag) THEN
               v = 0._LSRP
               DO a=1, lhs%face(faIn)%nNo
                  Ac = lhs%face(faIn)%glob(a)
                  DO i=1, nsd
                     v(i,Ac) = lhs%face(faIn)%valM(i,a)
                  END DO
               END DO
               lhs%face(faIn)%nS = FSILS_NORMV(nsd, mynNo, lhs%commu,   &
     &            v)**2._LSRP
            ELSE
               lhs%face(faIn)%nS = 0._LSRP
               DO a=1, lhs%face(faIn)%nNo
                  Ac = lhs%face(faIn)%glob(a)
                  DO i=1, nsd
                     lhs%face(faIn)%nS = lhs%face(faIn)%nS +            &
     &                  lhs%face(faIn)%valM(i,a)**2._LSRP
                  END DO
               END DO
            END IF
         END IF
      END DO

      RETURN
      END SUBROUTINE BCPRE
!--------------------------------------------------------------------
      SUBROUTINE DEPART
      IMPLICIT NONE

      INTEGER(KIND=LSIP) i, j, k, l, nnz

      REAL(KIND=LSRP), ALLOCATABLE :: tmp(:)

      nnz = lhs%nnz

      ALLOCATE(mK(nsd*nsd,nnz), mG(nsd,nnz), mD(nsd,nnz), mL(nnz),      &
     &   Gt(nsd,nnz), tmp((nsd+1)*(nsd+1)))

      IF (nsd .EQ. 2) THEN
         DO i=1, nnz
            tmp = Val(:,i)

            mK(1,i) = tmp(1)
            mK(2,i) = tmp(2)
            mK(3,i) = tmp(4)
            mK(4,i) = tmp(5)

            mG(1,i) = tmp(3)
            mG(2,i) = tmp(6)

            mD(1,i) = tmp(7)
            mD(2,i) = tmp(8)

            mL(i)   = tmp(9)
         END DO
      ELSE IF(nsd .EQ. 3) THEN
         DO i=1, nnz
            tmp = Val(:,i)

            mK(1,i) = tmp(1)
            mK(2,i) = tmp(2)
            mK(3,i) = tmp(3)
            mK(4,i) = tmp(5)
            mK(5,i) = tmp(6)
            mK(6,i) = tmp(7)
            mK(7,i) = tmp(9)
            mK(8,i) = tmp(10)
            mK(9,i) = tmp(11)

            mG(1,i) = tmp(4)
            mG(2,i) = tmp(8)
            mG(3,i) = tmp(12)

            mD(1,i) = tmp(13)
            mD(2,i) = tmp(14)
            mD(3,i) = tmp(15)

            mL(i)   = tmp(16)
         END DO
      ELSE
         PRINT *, "FSILS: Not defined nsd for DEPART", nsd
         STOP "FSILS: FATAL ERROR"
      END IF

      DO i=1, nNo
         Do j=lhs%rowPtr(1,i), lhs%rowPtr(2,i)
            k = lhs%colPtr(j)
            DO l=lhs%rowPtr(1,k), lhs%rowPtr(2,k)
               IF (lhs%colPtr(l) .EQ. i) THEN
                  Gt(:,l) = -mG(:,j)
                  EXIT
               END IF
            END DO
         END DO
      END DO

      RETURN
      END SUBROUTINE DEPART
!--------------------------------------------------------------------
      END SUBROUTINE PCGMRES
!####################################################################
