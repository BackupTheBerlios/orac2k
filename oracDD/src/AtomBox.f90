MODULE AtomBox

!!$***********************************************************************
!!$   Time-stamp: <2007-01-17 17:48:02 marchi>                           *
!!$                                                                      *
!!$                                                                      *
!!$                                                                      *
!!$======================================================================*
!!$                                                                      *
!!$              Author:  Massimo Marchi                                 *
!!$              CEA/Centre d'Etudes Saclay, FRANCE                      *
!!$                                                                      *
!!$              - Wed Jan 17 2007 -                                     *
!!$                                                                      *
!!$***********************************************************************

!!$---- This subroutine is part of the program oracDD ----*

  USE Units
  USE Cell
  USE PDB
  USE AtomCnt
  USE SystemPrm
  USE Solvent
  USE Errors, ONLY: Add_Errors=>Add, Print_Errors, error_args, errmsg_f
  IMPLICIT none
  PRIVATE
  PUBLIC AtomBox_, AtomBox__BuildSlv, AtomBox__
  TYPE :: AtomBox__
     INTEGER :: Serial
     REAL(8) :: sigma
     REAL(8) :: x,y,z
  END TYPE AtomBox__
  
CONTAINS
  SUBROUTINE AtomBox_(PDB__Coords, Coords)
    TYPE(AtomPdb) :: PDB__Coords(:)
    TYPE(AtomBox__), POINTER :: Coords(:)
    INTEGER :: n,m
    IF(ALLOCATED(PDB__Coords)) ALLOCATE(Coords(SIZE(PDB__Coords)))
    Coords(:) % x = PDB__Coords(:) % x
    Coords(:) % y = PDB__Coords(:) % y
    Coords(:) % z = PDB__Coords(:) % z
    Coords(:) % Serial = PDB__Coords(:) % Serial
    DO n=1,SIZE(PDB__Coords)
       m=AtomCnts(PDB__Coords(n) % Serial) % Id_Type
       Coords(n) % Sigma = Prm % LJ % Par_SE (m) % g(1)
    END DO
  END SUBROUTINE AtomBox_
  FUNCTION AtomBox__BuildSlv(Coords) RESULT(out)
    TYPE(AtomBox__), POINTER :: Coords(:)
    INTEGER, INTRINSIC :: count
    LOGICAL :: out
    INTEGER :: Ic, Jc, Kc
    INTEGER :: n,i_Type,o,p,q,m,l
    REAL(8) :: cube,cube_side,a0,b0,c0,volume0,x,y,z,x_0,y_0,z_0&
         &,cube_x,cube_y,cube_z
    INTEGER :: i_dvol(1),nCoords,offset
    REAL(8), ALLOCATABLE :: Dvol(:)
    TYPE(AtomBox__), ALLOCATABLE :: Coords0(:)
    out=.TRUE.


    IF(Solvent__Param % rho > 0.0D0) THEN
       ALLOCATE(Dvol(SIZE(Solvent__Box)))
       DO n=1,SIZE(Solvent__Box)
          cube=(1.0D0/Solvent__Param % rho)*DBLE(Solvent__Box(n) % nt)
          Cube_Side=cube**(1.0D0/3.0D0)
          Ic=a/Cube_Side; Jc=b/Cube_Side ; Kc=c/Cube_Side
          a0=Ic*Cube_Side; b0=Jc*Cube_Side; c0=Kc*Cube_Side
          volume0=Cell__Volume(a0,b0,c0,alpha,beta,gamma)
          Dvol(n)=ABS(volume-volume0)
       END DO
       i_dvol=MINLOC(Dvol)
       i_Type=i_Dvol(1)
       cube=(1.0D0/Solvent__Param % rho)*DBLE(Solvent__Box(i_Type) % nt)
       Cube_Side=cube**(1.0D0/3.0D0)
       Ic=a/Cube_Side; Jc=b/Cube_Side ; Kc=c/Cube_Side
       DEALLOCATE(Dvol)

    ELSE IF(COUNT(Solvent__Param % replicate /= 0) /= 0) THEN
       DO n=1,SIZE(Solvent__Box)
          IF(TRIM(Solvent__Box(n) % type) == TRIM(Solvent__Param % Cell_Type)) THEN
             i_Type=n
             EXIT
          END IF
       END DO
       Ic=Solvent__Param % Replicate(1); Jc=Solvent__Param % Replicate(2); Kc=Solvent__Param % Replicate(3)
    ELSE
       errmsg_f='Can''t build Simulation box without solvent density&
            & or replicate parameters '
       CALL Add_Errors(-1,errmsg_f)
       out=.FALSE.; RETURN
    END IF
    cube_x=boxl/DBLE(Ic)
    cube_y=boxl/DBLE(Jc)
    cube_z=boxl/DBLE(Kc)
    

    ALLOCATE(Coords0 (Solvent__Box(i_Type) % nt*Ic*Jc*Kc*SIZE(Coords)))
    nCoords=SIZE(Coords)
    m=0
    offset=0
    DO o=1,Ic
       x_0=DBLE(Ic-1)*cube_x
       DO p=1,Jc
          y_0=DBLE(Jc-1)*cube_y
          DO q=1,Kc
             z_0=DBLE(Kc-1)*cube_z
             DO n=1,Solvent__Box(i_Type) % nt
                x=x_0+Solvent__Box(i_Type) % T(o,n)
                y=y_0+Solvent__Box(i_Type) % T(p,n)
                z=z_0+Solvent__Box(i_Type) % T(q,n)
                DO l=1,nCoords
                   m=m+1
                   Coords0(m) % x = Coords(l) % x + co(1,1)*x + co(1,2)*y + co(1,3)*z 
                   Coords0(m) % y = Coords(l) % y + co(2,1)*x + co(2,2)*y + co(2,3)*z 
                   Coords0(m) % z = Coords(l) % z + co(3,1)*x + co(3,2)*y + co(3,3)*z
                   Coords0(m) % sigma = Coords(l) % sigma
                   Coords0(m) % Serial = Coords(l) % Serial + offset
                END DO
                offset=offset+nCoords
             END DO
          END DO
       END DO
    END DO
    DEALLOCATE(Coords)
    ALLOCATE(Coords(SIZE(Coords0)))
    Coords=Coords0
    WRITE(*,*) SIZE(Coords),Coords(120) % x
  END FUNCTION AtomBox__BuildSlv

!!$----------------- END OF EXECUTABLE STATEMENTS -----------------------*

END MODULE AtomBox
