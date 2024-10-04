program mathdemo

  use parameters
  implicit none

  real(dblprec), dimension(3) :: x,y,z
  x = (/7, 6, 3/)
  y=  (/8, 9, 5/)
  call crossproduct(x,y,z)
  write(*,10001) 'The cross product of'
  write(*,10002)  'x=', x, 'and'
  write(*,10002)  'y=', y, 'is'
  write(*,10002)  'z=', z

10001 format (a,f12.6,a)
10002 format (a,3f12.6)

end program mathdemo
