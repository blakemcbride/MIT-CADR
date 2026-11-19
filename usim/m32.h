#pragma once

#include <stdint.h>

/*
 * add32 and sub32 are called with mdata and adata, which are signed
 * int, and their `co' feeds alu_carry.  alu_carry is not a carry out:
 * outControl() shifts it into bit 31 as "the correct sign shifted in,
 * regardless of overflow", and divOps() sets it by hand from a sign
 * bit, so what is wanted is bit 32 of the 33-bit signed result.
 *
 * add32 computes exactly that.  `b > ~a' is a signed comparison here,
 * and is true precisely when a + b >= 0, so `co' comes out as the sign
 * of the sum -- not the unsigned carry the expression looks like.
 *
 * sub32 computes the same thing, but in the 33 bits directly rather
 * than by a trick.  It used to report an unsigned borrow instead,
 * which differs from the sign in half of all operand pairs.
 *
 * Both are two assignments, so they are wrapped in do..while to stay
 * one statement; without that an unbraced if..else around one of them
 * does not compile, or worse.
 */
#define add32(a, b, ci, out, co)					\
	do {								\
		out = ((uint32_t) a) + (b) + ((ci) ? 1 : 0);		\
		co = (ci) ? (((b) >= ~(a)) ? 0:1) : (((b) > ~(a)) ? 0:1); \
	} while (0)
#define sub32(a, b, ci, out, co)					\
	do {								\
		out = (a) - (b) - ((ci) ? 0 : 1);			\
		co = (((int64_t) (int32_t) (a) - (int64_t) (int32_t) (b)	\
		       - ((ci) ? 0 : 1)) < 0) ? 1 : 0;			\
	} while (0)
#define abs32(a)				\
	(a) < 0 ? ~(a) + 1 : (a)

extern uint32_t rol32(uint32_t, int);
