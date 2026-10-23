program main
 use models
 implicit none
 integer::kind,ios
 real(8)::I,tmax,on,off
 character(256)::s,file
 call get_command_argument(1,s);read(s,*,iostat=ios)kind
 if(ios/=0)stop 'Usage: simulate kind I tmax on off output.csv'
 call get_command_argument(2,s);read(s,*)I
 call get_command_argument(3,s);read(s,*)tmax
 call get_command_argument(4,s);read(s,*)on
 call get_command_argument(5,s);read(s,*)off
 call get_command_argument(6,file)
 call run(kind,I,tmax,on,off,trim(file))
end program
