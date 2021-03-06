// exception handling
.macro ventry label
.align 7
	b \label
.endm

.macro	kernel_entry
	sub	sp, sp, 512
	stp	x0, x1, [sp, #16 * 0]
	stp	x2, x3, [sp, #16 * 1]
	stp	x4, x5, [sp, #16 * 2]
	stp	x6, x7, [sp, #16 * 3]
	stp	x8, x9, [sp, #16 * 4]
	stp	x10, x11, [sp, #16 * 5]
	stp	x12, x13, [sp, #16 * 6]
	stp	x14, x15, [sp, #16 * 7]
	stp	x16, x17, [sp, #16 * 8]
	stp	x18, x19, [sp, #16 * 9]
	stp	x20, x21, [sp, #16 * 10]
	stp	x22, x23, [sp, #16 * 11]
	stp	x24, x25, [sp, #16 * 12]
	stp	x26, x27, [sp, #16 * 13]
	stp	x28, x29, [sp, #16 * 14]
	mrs	x22, elr_el1
	mrs	x23, spsr_el1

	stp	x30, x22, [sp, #16 * 15]
	str	x23, [sp, #16 * 16]
.endm

.macro	kernel_exit
	ldr	x23, [sp, #16 * 16]
	ldp	x30, x22, [sp, #16 * 15]

	msr	elr_el1, x22
	msr	spsr_el1, x23

	ldp	x0, x1, [sp, #16 * 0]
	ldp	x2, x3, [sp, #16 * 1]
	ldp	x4, x5, [sp, #16 * 2]
	ldp	x6, x7, [sp, #16 * 3]
	ldp	x8, x9, [sp, #16 * 4]
	ldp	x10, x11, [sp, #16 * 5]
	ldp	x12, x13, [sp, #16 * 6]
	ldp	x14, x15, [sp, #16 * 7]
	ldp	x16, x17, [sp, #16 * 8]
	ldp	x18, x19, [sp, #16 * 9]
	ldp	x20, x21, [sp, #16 * 10]
	ldp	x22, x23, [sp, #16 * 11]
	ldp	x24, x25, [sp, #16 * 12]
	ldp	x26, x27, [sp, #16 * 13]
	ldp	x28, x29, [sp, #16 * 14]
	add	sp, sp, 512
	eret
.endm

.macro unhandled_exception type
	kernel_entry
	mov x0, #\type
	mrs x1, esr_el1
	mrs x2, elr_el1
	mrs x3, far_el1
	bl print_unhandled_exception
	b honeypot // send to honeypot
.endm

honeypot:
	nop
	b honeypot

.align	11
.section .vectors, "ax"
.globl _vectors
_vectors:
	ventry	sync		// Synchronous EL1 (with EL0 stack)
	ventry	irq		// IRQ EL1 (with EL0 stack)
	ventry	fiq		// FIQ EL1 (with EL0 stack)
	ventry	error		// Error EL1 (with EL0 stack)
	ventry	sync		// Synchronous EL1 (with EL1 stack)
	ventry	irq		// IRQ EL1 (with EL1 stack)
	ventry	fiq		// FIQ EL1 (with EL1 stack)
	ventry	error		// Error EL1 (with EL1 stack)
	ventry	sync		// Synchronous EL1 (with EL1 stack)
	ventry	irq		// IRQ EL1 (with EL1 stack)
	ventry	fiq		// FIQ EL1 (with EL1 stack)
	ventry	error		// Error EL1 (with EL1 stack)
	ventry	sync		// Synchronous EL1 (with EL1 stack)
	ventry	irq		// IRQ EL1 (with EL1 stack)
	ventry	fiq		// FIQ EL1 (with EL1 stack)
	ventry	error		// Error EL1 (with EL1 stack)

sync:
	unhandled_exception 0

irq:
	kernel_entry
	bl handle_irq
	kernel_exit

fiq:
	unhandled_exception 2

error:
	unhandled_exception 3

.globl enable_irq
enable_irq:
	msr daifclr, #2
	ret

.globl disable_irq
disable_irq:
	msr daifset, #2
	ret
