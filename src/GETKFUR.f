C     NICHEMAPR: SOFTWARE FOR BIOPHYSICAL MECHANISTIC NICHE MODELLING

C     COPYRIGHT (C) 2020 MICHAEL R. KEARNEY AND WARREN P. PORTER

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

C     THIS SUBROUTINE COMPUTES FEASIBLE HAIR SPACING AND PARAMETERS
C     NEEDED FOR COMPUTING CONDUCTION & INFRARED RADIATION THROUGH THE FUR.

      SUBROUTINE GETKFUR(RHOAR,LHAR,ZZFUR,DHAR,KAIR,KHAIR,RESULTS)

      IMPLICIT NONE

      DOUBLE PRECISION AAIR,AHAIR,B1ARA,BETARA,DHAR,HAIRSP,KAIR
      DOUBLE PRECISION KEFARA,KHAIR,KX,KY,LHAR,LUNIT,PI,RAIR,RESULTS
      DOUBLE PRECISION RHAIR,RHOAR,RHOCM2,RHOEFF,TEST,W,ZZFUR

      DIMENSION RESULTS(3)

C     SPECIFIC PARTS OF THE BODY FOR PROPERTIES:
C     INDEX = AVERAGE, DORSAL/FRONT, VENTRAL/BACK VALUES
C     DHAR = HAIR DIAMETER, LHAR = HAIR/FEATHER LENGTH, RHOAR = HAIR DENSITY, ZFUR = FUR/PLUMAGE DEPTH
C     REFLFR = FUR/FEATHER REFLECTIVITES

      PI = 3.14159

C     CALCULATING EFFECTIVE DENSITY FOR THE PART OF THE ANIMAL
      RHOEFF=RHOAR*(LHAR/ZZFUR) ! TOP OF P. 254 IN CONLEY AND PORTER 1986
C     WRITE(0,*)'RHOEFF,L,RHOAR =',RHOEFF,L,RHOAR
      W=1.0 ! AN UNUSED WEIGHTING FACTOR
      LUNIT=1./RHOEFF**0.5 ! DISTANCE BETWEEN CENTER OF HAIRS (ASSUMING UNIFORM SPACING)
      HAIRSP = LUNIT-DHAR ! DISTANCE BETWEEN HAIRS
      TEST=1.
C     WRITE(0,*)'IDAY,IHOUR,PARTNO,L,RHOEFF,LUNIT,HAIRSP = '
C     WRITE(0,*)IDAY,IHOUR,PARTNO,L,RHOEFF,LUNIT,HAIRSP
C     IF((IHOUR.EQ.2).AND.(PARTNO.EQ.3))THEN
C      WRITE(0,*)'RHOARA,LHARA,ZFURAR = '
C      WRITE(0,*) RHOARA,LHARA,ZFURAR
C     ENDIF
C     CHECKING FOR FEASIBLE HAIR DENSITY/DIAMETER VALUES
      IF (HAIRSP .GT. 0.0000000000000) THEN
C      NO CORRECTIONS NEEDED, PROCEED.  LC IN KOWALSKI THESIS IS LUNIT VARIABLE HERE.
C      EQ. 3-23, P.80, KOWALSKI THESIS
       AAIR=(W/2.)*(LUNIT-DHAR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      EQ. 3-21, P 79 KOWALSKI THESIS; EQUIVALENT & LONGER FORM ON P 80, EQ. 3-21A
       RAIR=LUNIT/(KAIR*AAIR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      EQ. 3-24, P.80 KOWALSKI THESIS
       RHAIR=(((DHAR*KAIR)+(LUNIT-DHAR)*KHAIR))/
     &  (W*DHAR*KHAIR*KAIR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      EQUATION 3.19, KOWALSKI, P. 76, RATIO OF THE TOTAL HAIR X-SECT. AREA/UNIT FUR AREA
       AHAIR=RHOAR*((DHAR/2.)**2.*PI) ! AREA OF ONE HAIR TIMES DENSITY OF HAIRS PER M2
C      EQUATION 3.18 IN KOWALSKI, P.76
       KX=AHAIR*KHAIR+((1.-AHAIR)*KAIR) ! EQ 4 IN CONLEY AND PORTER 1986, BUT NO NEED TO DIVIDE BY AREA OF FUR BECAUSE ASSUMING UNIT AREA
C      EQUATION 3.26 IN KOWALSKI, P.81
       KY=(2./RAIR) + (1./RHAIR) ! EQUIVALENT TO EQ 5 IN CONLEY AND PORTER 1986
      ELSE
C      WRITE(0,*)'NO SPACE BETWEEN HAIR ELEMENTS'
       IF (HAIRSP .LT. 0.0000000) THEN
C       IF((HOURFLUX.EQ.'Y').OR.(HOURFLUX.EQ. 'Y'))THEN
C        WRITE(I2,*)'HAIR DIAMETER TOO LARGE FOR DENSITY.'
C        WRITE(I2,*)'SPACING, DIAMETER(M) = ',HAIRSP,DHAR
C    &       (JJ,L)
C       ENDIF
C       RECALCULATING DENSITY BASED ON SPECIFIED HAIR DIAMETER
        LUNIT = DHAR
        RHOEFF = 1./LUNIT**2
        RHOAR = (RHOEFF*ZZFUR)/LHAR
        RHOCM2 = RHOAR/10000.
C       WRITE(0,*)'RESETTING HAIR DENSITY TO MAX. POSBL VALUE.'
C       WRITE(0,*)'MAX. VALUE = ',RHOCM2,' HAIRS/CM2'
       ELSE
C       IF((HOURFLUX.EQ.'Y').OR.(HOURFLUX.EQ. 'Y'))THEN
C        WRITE(I2,*)'HAIR SPACING, DIAMETER(M) = ',
C    &     HAIRSP,DHAR(JJ,L)
C       ENDIF
       ENDIF
C      END OF RESETTING DENSITY
C      EQ. 3-23, P.80, KOWALSKI THESIS
       AAIR=(W/2.)*(LUNIT-DHAR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      EQ. 3-21, P 79 KOWALSKI THESIS; EQUIVALENT & LONGER FORM ON P 80, EQ. 3-21A
       RAIR=LUNIT/(KAIR*AAIR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      EQ. 3-24, P.80 KOWALSKI THESIS
       RHAIR=(((DHAR*KAIR)+(LUNIT-DHAR)*
     &  KHAIR))/(W*DHAR*KHAIR*KAIR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      EQUATION 3.19, KOWALSKI, P. 76, RATIO OF THE TOTAL HAIR X-SECT. AREA/UNIT FUR AREA
       AHAIR=RHOEFF*((DHAR/2.)**2.*PI) ! AREA OF ONE HAIR TIMES DENSITY OF HAIRS PER M2
C      EQUATION 3.18 IN KOWALSKI, P.76
       KX=AHAIR*KHAIR+((1.-AHAIR)*KAIR) ! EQ 4 IN CONLEY AND PORTER 1986, BUT NO NEED TO DIVIDE BY AREA OF FUR BECAUSE ASSUMING UNIT AREA
C      EQUATION 3.26 IN KOWALSKI, P.81
       KY=(2./RAIR) + (1./RHAIR) ! EQUIVALENT TO EQ 5 IN CONLEY AND PORTER 1986, BUT THEY HAD ERRONEOUSLY ADDED A RHOEFF^0.5 IN FIRST TERM
       HAIRSP = LUNIT-DHAR
C      FINDING THERMAL RESISTANCE AND CONDUCTANCES FOR THE 'UNIT' CELL
C      DERIVED 13,14 NOV. 1991 BY W.PORTER.  NOTES IN SMALL COPY OF
C      KOWALSKI'S THESIS FROM U. MICROFILMS, ANN ARBOR, MI.
       RAIR=2./((RHOEFF**0.5)*KAIR*(LUNIT-DHAR)*W) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      CHECK RHAIR FOR PARENTHESES IN RIGHT PLACE 3 JAN 2003
       RHAIR=(DHAR*KAIR+(LUNIT-DHAR)*KHAIR)/
     &  (W*DHAR*KHAIR*KAIR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
       AAIR=(W/2.)*(LUNIT-DHAR) ! PART OF EQ 5 IN CONLEY AND PORTER 1986
C      EQUATION 3.26 IN KOWALSKI, P.81
       KY=(2./RAIR)+(1./RHAIR) ! EQUIVALENT TO EQ 5 IN CONLEY AND PORTER 1986, BUT THEY HAD ERRONEOUSLY ADDED A RHOEFF^0.5 IN FIRST TERM
      ENDIF
C     END OF HAIR SPACE CORRECTIONS
C     KEFF = (KY+KX)/2.
C     EQUATION 3-28 KOWALSKI P. 82
      KEFARA=(KY+KX)/2. ! P. 253 IN CONLEY AND PORTER 1986
C     CHECK TO ENSURE KAIR<KEFF<KHAIR
      IF (KEFARA .GT. KHAIR) THEN
C      KEFF TOO HIGH
       KEFARA=KHAIR
      ELSE
       IF (KEFARA .LT. KAIR) THEN
C       KEFF TOO LOW
C       IF((HOURFLUX.EQ.'Y').OR.(HOURFLUX.EQ. 'Y'))THEN
C        WRITE(I2,134)KEFARA(JJ,L)
C       ENDIF
        KEFARA=KAIR
       ENDIF
      ENDIF
C     END OF CHECK FOR VALUE OF KEFF
      BETARA=(0.67/PI)*RHOEFF*DHAR! AVERAGE ABSORPTION COEFFICIENT, EQ6 IN CONLEY AND PORTER 1986
C     OPTICAL THICKNESS = B1
      B1ARA=BETARA*ZZFUR

      RESULTS = (/KEFARA,BETARA,B1ARA/)
      RETURN
      END
