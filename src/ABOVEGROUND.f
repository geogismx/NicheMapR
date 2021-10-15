      SUBROUTINE ABOVEGROUND

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
C
C     COMPUTES ABOVEGROUND MICROCLIMATE TO WHICH THE ANIMAL IS EXPOSED

      USE AACOMMONDAT
      IMPLICIT NONE
      EXTERNAL FUN

      DOUBLE PRECISION A1,A2,A3,A4,A4B,A5,A6,ABSAN,ABSSB,AL,ALT,AMASS
      DOUBLE PRECISION ANDENS,AREF,ASIL,ASILN,ASILP,ATOT,BP,BREF,CP,CREF
      DOUBLE PRECISION DB,DENAIR,DEPSUB,DP,DSHD,E,EGGPTCOND,EMISAN
      DOUBLE PRECISION EMISSB,EMISSK,ESAT,F12,F13,F14,F15,F16,F21,F23
      DOUBLE PRECISION F24,F25,F26,F31,F32,F41,F42,F51,F52,F61,FATOBJ
      DOUBLE PRECISION FATOSB,FATOSK,FLSHCOND,FLUID,FLYMETAB,FLYSPEED
      DOUBLE PRECISION FLYTIME,FUN,G,H2O_BALPAST,HRN,HSHSOI,HSOIL,MAXSHD
      DOUBLE PRECISION MICRO,MSHSOI,MSOIL,NM,PATMOS,PDIF,PHI,PHIMAX
      DOUBLE PRECISION PHIMIN,PI,POND_DEPTH,PSHSOI,PSOIL,PSTD,PTCOND
      DOUBLE PRECISION PTCOND_ORIG,QSOL,QSOLR,R,RELHUM,RH,RHO1_3,RHREF
      DOUBLE PRECISION RW,SHADE,SIDEX,SIG,SUBTK,TA,TALOC,TANNUL,TIME
      DOUBLE PRECISION TOBJ,TQSOL,TR,TRANS1,TREF,TSHLOW,TSHSKI,TSHSOI
      DOUBLE PRECISION TSKIN,TSKY,TSKYC,TSOIL,TSUB,TSUBST,TVINC,TVIR
      DOUBLE PRECISION TWATER,TWING,VAPREF,VD,VEL,VLOC,VREF,WB,WC,WEVAP
      DOUBLE PRECISION WQSOL,WTRPOT,Z,ZEN,ZSOIL,POT,TCOND,SHTCOND
      DOUBLE PRECISION K_SAT,BB,P_E,KSATS,BBS,PES

      INTEGER AQUATIC,CLIMBING,FEEDING,FLIGHT,FLYER,FLYTEST,IHOUR
      INTEGER INWATER,WINGCALC,WINGMOD

      DIMENSION HRN(25),HSHSOI(10),HSOIL(10),MSHSOI(10),MSOIL(10)
      DIMENSION PSHSOI(10),PSOIL(10),QSOL(25),RH(25),RHREF(25),TALOC(25)
      DIMENSION TIME(25),TREF(25),TSHLOW(25),TSHSKI(25),TSHSOI(10)
      DIMENSION TSKYC(25),TSOIL(10),TSUB(25),VLOC(25),VREF(25),Z(25)
      DIMENSION ZSOIL(10),TCOND(10),SHTCOND(10),KSATS(10),BBS(10)
      DIMENSION PES(10)
      
      COMMON/CLIMB/CLIMBING
      COMMON/ENVAR1/QSOL,RH,TSKYC,TIME,TALOC,TREF,RHREF,HRN
      COMMON/ENVAR2/TSUB,VREF,Z,TANNUL,VLOC
      COMMON/FLY/FLYTIME,FLYSPEED,FLYMETAB,FLIGHT,FLYER,FLYTEST
      COMMON/FUN2/AMASS,RELHUM,ATOT,FATOSK,FATOSB,EMISAN,SIG,FLSHCOND
      COMMON/FUN3/AL,TA,VEL,PTCOND,SUBTK,DEPSUB,TSUBST,PTCOND_ORIG,
     & EGGPTCOND,POT
      COMMON/FUN4/TSKIN,R,WEVAP,TR,ALT,BP,H2O_BALPAST
      COMMON/FUN5/WC,ZEN,PDIF,ABSSB,ABSAN,ASILN,FATOBJ,NM
      COMMON/PONDDATA/INWATER,AQUATIC,TWATER,POND_DEPTH,FEEDING
      COMMON/SHADE/MAXSHD,DSHD
      COMMON/SHENV1/TSHSKI,TSHLOW
      COMMON/SOIL/TSOIL,TSHSOI,ZSOIL,MSOIL,MSHSOI,PSOIL,PSHSOI,HSOIL,
     & HSHSOI,TCOND,SHTCOND
      COMMON/WINGFUN/RHO1_3,TRANS1,AREF,BREF,CREF,PHI,F21,F31,F41,F51
     &,SIDEX,WQSOL,PHIMIN,PHIMAX,TWING,F12,F32,F42,F52
     &,F61,TQSOL,A1,A2,A3,A4,A4B,A5,A6,F13,F14,F15,F16,F23,F24,F25,F26
     &,WINGCALC,WINGMOD
      COMMON/WSOLAR/ASIL,SHADE
      COMMON/WDSUB1/ANDENS,ASILP,EMISSB,EMISSK,FLUID,G,IHOUR
      COMMON/WDSUB2/QSOLR,TOBJ,TSKY,MICRO
      COMMON/WATERSUB/K_SAT,P_E,BB,KSATS,BBS,PES

      DATA PI/3.14159265/

C     NOTE: SHADMET COMES FROM THE % SHADE OF THE VEGETATION FOR THE GROUND.  THIS MIGHT BE <100%.
C     HOWEVER, SMALL ANIMALS MAY STILL BE ABLE TO SEEK 100% SHADE.  IN THAT
C     CASE, THE RADIANT ENVIRONMENT WILL BE THAT OF THE LOCAL AIR TEMPERATURE (NOT IMPLEMENTED HERE).

C     SOLAR ENVIRONMENT
      QSOLR = QSOL(IHOUR)*((100.-SHADE)/100.) !ADJUST SOLAR FOR SHADE
      ZEN = Z(IHOUR) * PI / 180. !GET SOLAR ZENITH ANGLE (RADIANS)

C     CONVECTIVE AND HUMIDITY ENVIRONMENT
      IF(FLYTEST.EQ.1)THEN ! ASSUME FLYING AT 2M
       TA = TREF(IHOUR)
       VEL = FLYSPEED
       RELHUM = RHREF(IHOUR)
      ELSE
       IF(CLIMBING.EQ.1)THEN ! ASSUME HAS CLIMBED TO 2M
        TA = TREF(IHOUR)
        VEL = VREF(IHOUR)
       ELSE
       TA = TALOC(IHOUR)*((MAXSHD-SHADE)/MAXSHD) + ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     &    (TSHLOW(IHOUR)*(SHADE/MAXSHD))
       VEL = VLOC (IHOUR) ! CHOOSE LOCAL HEIGHT WIND SPEED
       ENDIF
C      ADJUST RELATIVE HUMIDITY TO NEW AIR TEMP
       RELHUM = RH(IHOUR)
       WB=0.
       DP=999.
C      BP CALCULATED FROM ALTITUDE USING THE STANDARD ATMOSPHERE
C      EQUATIONS FROM SUBROUTINE DRYAIR    (TRACY ET AL,1972)
       PSTD=101325.
       PATMOS=PSTD*((1.-(.0065*ALT/288.))**(1./.190284))
       BP = PATMOS
       DB = TALOC(IHOUR)
      CALL WETAIR(DB,WB,RELHUM,DP,BP,E,ESAT,VD,RW,TVIR,TVINC,
     * DENAIR,CP,WTRPOT)
       VAPREF = E
       DB = TA
       RELHUM=100
      CALL WETAIR(DB,WB,RELHUM,DP,BP,E,ESAT,VD,RW,TVIR,TVINC,
     * DENAIR,CP,WTRPOT)
       RELHUM = (VAPREF/ESAT)* 100.
       IF(RELHUM.GT.100.)THEN
        RELHUM = 100.
       ENDIF
       IF(RELHUM.LT.0.000)THEN
        RELHUM = 0.01
       ENDIF
      ENDIF
      
C     RADIANT ENVIRONMENT (SKY AND GROUND)
      TSKY=TSKYC(IHOUR)*((MAXSHD-SHADE)/MAXSHD)+(TSHSKI(IHOUR) ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     & *(SHADE/MAXSHD))
      TSUBST = TSOIL(1)*((MAXSHD-SHADE)/MAXSHD) + TSHSOI(1)* ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     & (SHADE/MAXSHD)

C     AQUATIC ENVIRONMENT
      IF(INWATER.EQ.1)THEN ! THIS MIGHT NOT BE NECESSARY
       TSUBST=TWATER
       TSKY=TWATER
      ENDIF
      
C	  SOIL ENVIRONMENT FOR CONDUCTION AND LIQUID WATER EXCHANGE
      IF(CLIMBING.EQ.1)THEN ! ASSUME HAS CLIMBED TO 2M
C      !!NOTE THAT FRACTION CONTACTING GROUND CURRENTY SET TO ZERO IF CLIMBING IN SUB. GEOM!!
       SUBTK=0.10 ! WOOD ALSO HAS A THERMAL COND. 0.10-0.35 W/M-C
      ELSE
       SUBTK=TCOND(1)*((MAXSHD-SHADE)/MAXSHD)+(SHTCOND(1) ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     & *(SHADE/MAXSHD))
      ENDIF
      POT=PSOIL(1)*((MAXSHD-SHADE)/MAXSHD)+(PSHSOI(1) ! WEIGHTED MEAN OF VALUE IN MIN AND MAX AVAILABLE SHADE ACCORDING TO %SHADE CHOSEN
     & *(SHADE/MAXSHD)) 
      BB=BBS(1)
      K_SAT=KSATS(1)
      P_E=PES(1)
      
      TOBJ = TSUBST ! ASSUMING NO NEARBY OBJECT IN THIS VERSION

      RETURN
      END