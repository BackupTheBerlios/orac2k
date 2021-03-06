MODULE TOPOLOGY_Mod

!!$***********************************************************************
!!$   Time-stamp: <2006-12-20 16:52:34 marchi>                           *
!!$                                                                      *
!!$                                                                      *
!!$                                                                      *
!!$======================================================================*
!!$                                                                      *
!!$              Author:  Massimo Marchi                                 *
!!$              CEA/Centre d'Etudes Saclay, FRANCE                      *
!!$                                                                      *
!!$              - Mon Nov 27 2006 -                                     *
!!$                                                                      *
!!$***********************************************************************

!!$---- This Module is part of the program ORAC ----*
  
  USE Class_SystemTpg, ONLY: SystemTpg__Init=>Init
  USE Class_SystemPrm, ONLY: SystemPrm__Init=>Init
  USE STRINGS_Mod, ONLY: MY_Fxm
  USE MYPARSE_Mod, ONLY: MY_parse=>parse, max_pars
  USE TYPES_Utils
  USE ERROR_Mod,ONLY: Add_error=>Add
  USE PARAMETERS_GLOBALS
  USE TOPOLOGY_GLOBALS
  IMPLICIT none
  PRIVATE
  PUBLIC :: SetupTpg, SetupPrm
  
CONTAINS
  SUBROUTINE SetupTPG
    
    CALL New_Residues
    CALL SystemTpg__Init

  END SUBROUTINE SetupTPG
  SUBROUTINE SetupPrm
    
    CALL SystemPrm__Init

  END SUBROUTINE SetupPrm
  INCLUDE 'New_Residues.f90'
END MODULE TOPOLOGY_Mod
