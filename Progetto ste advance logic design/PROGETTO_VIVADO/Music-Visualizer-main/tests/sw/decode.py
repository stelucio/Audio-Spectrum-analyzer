
def decode_riscv(hex_str):
    val = int(hex_str, 16)
    opcode = val & 0x7F
    rd = (val >> 7) & 0x1F
    funct3 = (val >> 12) & 0x7
    rs1 = (val >> 15) & 0x1F
    rs2 = (val >> 20) & 0x1F
    funct7 = (val >> 25) & 0x7F
    
    print(f"Hex: {hex_str}")
    print(f"  Opcode: {hex(opcode)}")
    print(f"  RD/Imm: {rd}")
    print(f"  RS1:    {rs1}")
    print(f"  RS2:    {rs2}")
    print(f"  F3:     {funct3}")
    print(f"  F7:     {funct7}")

# Istruzioni trovate
# fe010113 = addi sp, sp, -32
# 00112e23 = sw ra, 28(sp)
# 00812c23 = sw s0, 24(sp)
instructions = ["fe010113", "00112e23", "00812c23"]
for instr in instructions:
    decode_riscv(instr)
