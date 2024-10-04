module parameters

   implicit none

   integer, parameter :: snglprec = selected_real_kind(6, 37)   !< define precision for single reals
   integer, parameter :: dblprec = selected_real_kind(15, 307)  !< define precision for double reals
   integer, parameter :: qdprec = selected_real_kind(33, 4931)  !< define precision for quad reals

end module parameters
