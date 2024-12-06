!==============================================================================
! This source code is part of the
! Australian Community Atmosphere Biosphere Land Exchange (CABLE) model.
! This work is licensed under the CSIRO Open Source Software License
! Agreement (variation of the BSD / MIT License).
!
! You may not use this file except in compliance with this License.
! A copy of the License (CSIRO_BSD_MIT_License_v2.0_CABLE.txt) is located
! in each directory containing CABLE code.
!
! ==============================================================================
! Purpose: Error management for CABLE offline
!
! Contact: Bernard.Pak@csiro.au
!
! History: Developed by Gab Abramowitz and Harvey Davies
!
!
! ==============================================================================

MODULE cable_abort_module

  USE cable_IO_vars_module, ONLY: check, logn
  IMPLICIT NONE

CONTAINS

  !==============================================================================
  !
  ! Name: abort
  !
  ! Purpose: Prints an error message and stops the code
  !
  ! CALLed from: get_default_inits
  !              get_restart_data
  !              get_default_lai
  !              open_met_file
  !              get_met_data
  !              load_parameters
  !              open_output_file
  !              write_output
  !              read_gridinfo
  !              countpatch
  !              get_type_parameters
  !              readpar_i
  !              readpar_r
  !              readpar_rd
  !              readpar_r2
  !              readpar_r2d
  !              define_output_variable_r1
  !              define_output_variable_r2
  !              define_output_parameter_r1
  !              define_output_parameter_r2
  !              write_output_variable_r1
  !              write_output_variable_r2
  !              write_output_parameter_r1
  !              write_output_parameter_r1d
  !              write_output_parameter_r2
  !              write_output_parameter_r2d
  !
  !==============================================================================

  SUBROUTINE abort(message)

    ! Input arguments
    CHARACTER(LEN=*), INTENT(IN) :: message

    WRITE (*, *) message
    STOP 1

  END SUBROUTINE abort

  !==============================================================================
  !
  ! Name: nc_abort
  !
  ! Purpose: For NETCDF errors. Prints an error message then stops the code
  !
  ! CALLed from: get_restart_data
  !              extrarestart
  !              get_default_lai
  !              open_met_file
  !              get_met_data
  !              close_met_file
  !              load_parameters
  !              open_output_file
  !              write_output
  !              close_output_file
  !              create_restart
  !              read_gridinfo
  !              readpar_i
  !              readpar_r
  !              readpar_rd
  !              readpar_r2
  !              readpar_r2d
  !              define_output_variable_r1
  !              define_output_variable_r2
  !              define_output_parameter_r1
  !              define_output_parameter_r2
  !              write_output_variable_r1
  !              write_output_variable_r2
  !              write_output_parameter_r1
  !              write_output_parameter_r1d
  !              write_output_parameter_r2
  !              write_output_parameter_r2d
  !
  ! MODULEs used: netcdf
  !
  !==============================================================================

  SUBROUTINE nc_abort(ok, message)

    USE netcdf

    ! Input arguments
    CHARACTER(LEN=*), INTENT(IN) :: message
    INTEGER, INTENT(IN) :: ok

    WRITE (*, *) message ! error from subroutine
    WRITE (*, *) NF90_STRERROR(ok) ! netcdf error details

    STOP

  END SUBROUTINE nc_abort

  !==============================================================================
  !
  ! Name: range_abort
  !
  ! Purpose: Prints an error message and localisation information then stops the
  !          code
  !
  ! CALLed from: write_output_variable_r1
  !              write_output_variable_r2
  !
  ! MODULEs used: cable_def_types_mod
  !               cable_IO_vars_module
  !
  !==============================================================================

  SUBROUTINE range_abort(vname, ktau, met, value, var_range, i, xx, yy)

    USE cable_def_types_mod, ONLY: met_type
    USE cable_IO_vars_module, ONLY: latitude, longitude, &
                                    landpt, lat_all, lon_all

    ! Input arguments
    CHARACTER(LEN=*), INTENT(IN) :: vname

    INTEGER, INTENT(IN) :: &
      ktau, & ! time step
      i       ! tile number along mp

    REAL, INTENT(IN) :: &
      xx, & ! coordinates of erroneous grid square
      yy    ! coordinates of erroneous grid square

    TYPE(met_type), INTENT(IN) :: met  ! met data

    REAL(4), INTENT(IN) :: value ! value deemed to be out of range

    REAL, INTENT(IN) :: var_range(2) ! appropriate var range

    INTEGER :: iunit

    IF (check%exit) THEN
      iunit = 6
    ELSE
      iunit = logn ! warning
    END IF

    WRITE (iunit, *) "in SUBR range_abort: Out of range"
    WRITE (iunit, *) "for var ", vname ! error from subroutine

    ! patch(i)%latitude, patch(i)%longitude
    WRITE (iunit, *) 'Site lat, lon:', xx, yy
    WRITE (iunit, *) 'Output timestep', ktau, &
      ', or ', met%hod(i), ' hod, ', &
      INT(met%doy(i)), 'doy, ', &
      INT(met%year(i))

    WRITE (iunit, *) 'Specified acceptable range (cable_checks.f90):', &
      var_range(1), 'to', var_range(2)

    WRITE (iunit, *) 'Value:', value

    IF (check%exit) THEN
      STOP
    END IF

  END SUBROUTINE range_abort

  !==============================================================================
END MODULE cable_abort_module
