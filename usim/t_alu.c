/* t_alu --- differential test of usim's ALU against a 74S181 reference
 *
 * The reference is the published 74181 function table (active-high
 * data) evaluated on operands sign-extended to 64 bits.  Bit 32 of
 * that result is what the CADR's fifth 74S181 slice produces --- alu1
 * 2a03 is fed the two sign bits, with the carry out of bit 31 as its
 * carry in and the same mode and function bits as the other four ---
 * and mo1 2a09 routes that into OB31 for OUTPUT-SELECTOR-RIGHTSHIFT-1.
 * So one expression gives both alu_out and alu_carry.
 *
 * The function select is the one cadr_aluc4 derives: for an ordinary
 * ALU operation S3=ir3, S2=ir4, S1=~ir6, S0=~ir5, M=~ir7 and the carry
 * in is ir2.  For a multiply or divide step the three 74S153s at 2b16,
 * 2b17 and 2b18 substitute a fixed function chosen by aluadd and
 * alusub, which 2c10/2c15/2c20 derive from Q0 and A31.  A is the M
 * source and B is the A source (alu1 2a03 has p2=>m31b and p1=>a31a).
 *
 * cadr_source 3d04 decodes -mul and -div from ir3 and ir4 when ir8 and
 * iralu are both set, so only operations 040 and up are conditional.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdbool.h>

extern void aluOps(uint32_t aluop);
extern void qControl(void);
extern uint64_t p0;
extern int mdata, adata;
extern uint32_t alu_out, alu_carry, q, old_q;

struct fn { int s; int m; int cin; };

/* cadr_aluc4: pick the ALU function actually presented to the chips. */
static struct fn
select_fn(uint32_t op, int q0, int a31, int ir2)
{
	int ir3 = op & 1, ir4 = (op >> 1) & 1, ir5 = (op >> 2) & 1;
	int ir6 = (op >> 3) & 1, ir7 = (op >> 4) & 1, ir8 = (op >> 5) & 1;

	/* cadr_source 3d04, a 74S139 enabled by -specalu = ir8 nand iralu */
	int n_mul = !(ir8 && ir4 == 0 && ir3 == 0);
	int n_div = !(ir8 && ir4 == 0 && ir3 == 1);

	int n_divposlasttime = !(q0 || ir6);
	int divsubcond = !(n_divposlasttime || n_div);
	int net_4 = !(ir5 || n_divposlasttime);
	int divaddcond = !(net_4 || n_div);
	int n_a31 = !a31;
	int net_0 = !(divsubcond && a31);
	int net_1 = !(divaddcond && n_a31);
	int net_2 = !(divsubcond && n_a31);
	int net_3 = !(divaddcond && a31);
	int n_mulnop = n_mul || q0;
	/* -irjump is 1 for an ALU instruction */
	int alusub = !(n_mulnop && net_2 && net_3 && 1);
	int aluadd = !(n_mul && 1 && net_0 && net_1);

	switch (alusub * 2 + aluadd) {
	case 1:	 return (struct fn) { 011, 0, 0 };	/* A plus B      */
	case 2:	 return (struct fn) { 006, 0, 1 };	/* A minus B - 1 */
	case 3:	 return (struct fn) { 017, 1, 1 };	/* logic, F = A  */
	default: return (struct fn) { (ir3 << 3) | (ir4 << 2) | (!ir6 << 1) | !ir5,
				      !ir7, ir2 };
	}
}

/* 74181, active-high data, on sign-extended operands. */
static int64_t
ref(struct fn f, int32_t a32, int32_t b32)
{
	int64_t A = a32, B = b32;

	if (f.m) {
		switch (f.s) {
		case 000: return ~A;
		case 001: return ~(A | B);
		case 002: return ~A & B;
		case 003: return 0;
		case 004: return ~(A & B);
		case 005: return ~B;
		case 006: return A ^ B;
		case 007: return A & ~B;
		case 010: return ~A | B;
		case 011: return ~(A ^ B);
		case 012: return B;
		case 013: return A & B;
		case 014: return ~(int64_t) 0;
		case 015: return A | ~B;
		case 016: return A | B;
		case 017: return A;
		}
	}
	switch (f.s) {
	case 000: return A + f.cin;
	case 001: return (A | B) + f.cin;
	case 002: return (A | ~B) + f.cin;
	case 003: return -1 + f.cin;
	case 004: return A + (A & ~B) + f.cin;
	case 005: return (A | B) + (A & ~B) + f.cin;
	case 006: return A - B - 1 + f.cin;
	case 007: return (A & ~B) - 1 + f.cin;
	case 010: return A + (A & B) + f.cin;
	case 011: return A + B + f.cin;
	case 012: return (A | ~B) + (A & B) + f.cin;
	case 013: return (A & B) - 1 + f.cin;
	case 014: return A + A + f.cin;
	case 015: return (A | B) + A + f.cin;
	case 016: return (A | ~B) + A + f.cin;
	case 017: return A - 1 + f.cin;
	}
	return 0;
}

static const int32_t vals[] = {
	0, 1, -1, 2, -2, 3, -3, 5, -5, 7, 0x55555555, (int32_t) 0xaaaaaaaa,
	0x7fffffff, (int32_t) 0x80000000, (int32_t) 0xffffffff,
	0x40000000, (int32_t) 0xc0000000, 0x0000ffff, (int32_t) 0xffff0000,
};
#define N ((int) (sizeof(vals) / sizeof(vals[0])))

static const char *nm(uint32_t op)
{
	static const char *l[] = { "SETZ","AND","ANDCA","SETM","ANDCM","SETA","XOR","IOR",
				   "ANDCB","EQV","SETCA","ORCA","SETCM","ORCM","ORCB","SETO" };
	if ((op & 040) && (op & 003) == 0) return "mul";
	if ((op & 040) && (op & 003) == 1) return "div";
	return (op & 037) < 020 ? l[op & 037] : "arith";
}

static int bad_out[0100], bad_carry[0100], total_out, total_carry, cases;

static void
one(uint32_t op, int32_t m, int32_t a, int cin, int q0)
{
	int64_t r = ref(select_fn(op, q0, (a < 0), cin), m, a);

	mdata = m;
	adata = a;
	q = q0;
	p0 = ((uint64_t) cin << 2) | ((uint64_t) op << 3);
	/* a sentinel, so a stale alu_out is visible rather than lucky */
	alu_out = 0xdeadbeef;
	alu_carry = 0xdeadbeef;
	aluOps(op);

	cases++;
	if (alu_out != (uint32_t) r) { bad_out[op]++; total_out++; }
	if (alu_carry != (uint32_t) ((r >> 32) & 1)) { bad_carry[op]++; total_carry++; }
}

/*
 * The Q register is eight 74S194s.  cadr_qctl 2b19 makes their S0 and
 * S1 ir0 and ir1, so 00 holds, 01 shifts one way, 10 the other and 11
 * loads in parallel.  A 74S194 shift right moves QA to QB, which is up
 * in bit number here since q_2c27 has QA as q0, and its serial input
 * on that slice is -alu31; a shift left moves the other way and the
 * serial input on the top slice, q_2c08, is alu0.
 */
static uint32_t
q_ref(uint32_t sel, uint32_t q_in, uint32_t alu)
{
	switch (sel) {
	case 1:  return (q_in << 1) | (~(alu >> 31) & 1);
	case 2:  return (q_in >> 1) | ((alu & 1) << 31);
	case 3:  return alu;
	default: return q_in;
	}
}

static int q_bad, q_old_bad, q_cases;

static void
one_q(uint32_t sel, uint32_t q_in, uint32_t alu)
{
	uint32_t want = q_ref(sel, q_in, alu);

	q = q_in;
	old_q = 0xdeadbeef;
	alu_out = alu;
	p0 = sel;
	qControl();

	q_cases++;
	if (q != want) q_bad++;
	if (old_q != q_in) q_old_bad++;
}

int
main(void)
{
	for (uint32_t sel = 0; sel < 4; sel++)
		for (int i = 0; i < N; i++)
			for (int j = 0; j < N; j++)
				one_q(sel, (uint32_t) vals[i], (uint32_t) vals[j]);

	for (uint32_t op = 0; op < 0100; op++)
		for (int i = 0; i < N; i++)
			for (int j = 0; j < N; j++)
				for (int cin = 0; cin < 2; cin++)
					for (int q0 = 0; q0 < 2; q0++)
						one(op, vals[i], vals[j], cin, q0);

	printf("%d cases: every ALU operation 000-077, over both values of Q0\n\n", cases);
	printf("  %-5s %-7s %-9s %-9s\n", "op", "name", "alu_out", "alu_carry");
	for (uint32_t op = 0; op < 0100; op++)
		if (bad_out[op] || bad_carry[op])
			printf("  %03o   %-7s %-9d %-9d\n", op, nm(op), bad_out[op], bad_carry[op]);
	printf("\ntotal: alu_out wrong in %d, alu_carry wrong in %d\n", total_out, total_carry);

	printf("\n%d cases: Q control over all four selections\n", q_cases);
	printf("total: q wrong in %d, old_q wrong in %d\n", q_bad, q_old_bad);

	return (total_out || total_carry || q_bad || q_old_bad) ? 1 : 0;
}
