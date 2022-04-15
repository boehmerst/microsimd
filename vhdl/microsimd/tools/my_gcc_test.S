        
        .globl _exit
        .align 2
        .ent _exit
        .type _exit, @function    
_exit:
        vadd.i8  n0, n1, n2
        vadd.i16 w0, w1, w2
        vadd.i32 w0, w1, w2
        
        bri     0
	.end _exit
	
