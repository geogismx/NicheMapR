      SUBROUTINE DGET_AELES(N,A,AELES,DAELES,RPAR,IPAR)

C     NICHEMAPR: SOFTWARE FOR BIOPHYSICAL MECHANISTIC NICHE MODELLING

C     COPYRIGHT (C) 2018 MICHAEL R. KEARNEY AND WARREN P. PORTER

C     THIS PROGRAM IS FREE SOFTWARE: YOU CAN REDISTRIBUTE IT AND/OR MODIFY
C     IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY
C     THE FREE SOFTWARE FOUNDATION, EITHER VERSION 3 OF THE LICENSE, OR (AT
C      YOUR OPTION) ANY LATER VERSION.

C     THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
C     WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
C     MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU
C     GENERAL PUBLIC LICENSE FOR MORE DETAILS.

C     YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE
C     ALONG WITH THIS PROGRAM. IF NOT, SEE HTTP://WWW.GNU.ORG/LICENSES/.

C     EQUATIONS TO COMPUTE RATES OF CHANGE IN RESERVE, STRUCTURAL LENGTH, 
C     REPRODUCTION BUFFER AND STOMACH ENERGY FOR AN INSECT LARVA

      IMPLICIT NONE
      INTEGER IPAR,N
      DOUBLE PRECISION A,AELES,DAELES,DE,DER,DES,DL,E,E_M,E_R,E_S,E_SC
      DOUBLE PRECISION E_SM,F,F2,G,K,K_E,K_M,KAP,KAP_X,L,P_A,P_AM,P_C
      DOUBLE PRECISION P_J,P_X,P_XM,R,RPAR,V,X
      DIMENSION AELES(N),DAELES(N),IPAR(13),RPAR(16)

      F=RPAR(1)
      K_M=RPAR(2)
      K_E=RPAR(3)
      P_J=RPAR(4)
      P_AM=RPAR(5)
      E_M=RPAR(6)
      G=RPAR(7)
      KAP=RPAR(8)
      P_XM=RPAR(9)
      X=RPAR(10)
      K=RPAR(11)
      F2=RPAR(12)
      KAP_X=RPAR(13)
      E_SM=RPAR(14)
      A  = AELES(1)! % D, TIME SINCE BIRTH
      E  = AELES(2)! % J, RESERVE
      L  = AELES(3)! % CM, STRUCTURAL LENGTH
      E_R= AELES(4)! % J, REPRODUCTION BUFFER
      E_S= AELES(5)! % J, STOMACH ENERGY

      V = L ** 3.D+00                         ! CM^3, STRUCTURAL VOLUME
      E_SC = E/ V/ E_M                        ! -, SCALED RESERVE DENSITY
      R = (E_SC * K_E - G * K_M)/ (E_SC + G)  ! 1/TIME, SPECIFIC GROWTH RATE
      P_C = E * (K_E - R)                     ! J/TIME, MOBILISATION RATE
      P_A = F * P_AM * V                      ! J/TIME, ASSIMILATION RATE, NOTE MULTPLYING BY V SINCE ALREADY DIVIDED BY L_B WHICH IS THE SAME AS MULT BY V^2/3 AND BY L/L_b
      P_X = P_XM * ((X / K) / (F2 + X / K)) * V ! J/TIME, FOOD ENERGY INTAKE RATE, NOTE MULTPLYING BY V SINCE ALREADY DIVIDED BY L_B WHICH IS THE SAME AS MULT BY V^2/3 AND BY L/L_b
      IF(E_S .LT. P_A)THEN                    ! NO ASSIMILATION IF STOMACH TOO EMPTY
       DE = E_S - P_C                         ! J/TIME, CHANGE IN RESERVE, NOTE MULTPLYING BY V SINCE ALREADY DIVIDED BY L_B WHICH IS THE SAME AS MULT BY V^2/3 AND BY L/L_b
      ELSE
       DE = F * P_AM * V - P_C                ! J/TIME, CHANGE IN RESERVE, NOTE MULTPLYING BY V SINCE ALREADY DIVIDED BY L_B WHICH IS THE SAME AS MULT BY V^2/3 AND BY L/L_b
      ENDIF
      DL = R * L/ 3.D+00                      ! CM/TIME, CHANGE IN LENGTH
      DER = (1.D+00 - KAP) * P_C - P_J        ! J/TIME, CHANGE IN REPROD BUFFER
      DES = P_X - F * (P_AM / KAP_X) * V      ! J/TIME, CHANGE IN STOMACH ENERGY, NOTE MULTPLYING BY V SINCE ALREADY DIVIDED BY L_B WHICH IS THE SAME AS MULT BY V^2/3 AND BY L/L_b

      DAELES(1)=1.0D+00
      DAELES(2)=DE
      DAELES(3)=DL
      DAELES(4)=DER
      DAELES(5)=DES

      RETURN
      END