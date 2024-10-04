!cross product of two 3-vectors a and b
subroutine crossproduct(a,b,c)

  use parameters
  implicit none

  real(dblprec), dimension(3),intent(in) :: a  !< Left factor
  real(dblprec), dimension(3),intent(in) :: b  !< Right factor
  real(dblprec), dimension(3),intent(out) :: c  !< The cross product of a and b

  c(1) = a(2) * b(3) - a(3) * b(2)
  c(2) = a(3) * b(1) - a(1) * b(3)
  c(3) = a(1) * b(2) - a(2) * b(1)
  return

end subroutine crossproduct
