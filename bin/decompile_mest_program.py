import re
import argparse
from sys import stdout, stderr
import fileinput


opcodes_vh = """
`ifndef _opcodes_vh_
`define _opcodes_vh_

`define OP_ADD 'b00000000
`define OP_SUB 'b00000001
`define OP_MULTIPLY 'b00000010
`define OP_AND 'b00000011
`define OP_OR 'b00000100
`define OP_SROP1 'b00000101
`define OP_SLOP1 'b00000110
`define OP_NEGOP1 'b00000111
`define OP_JMP 'b00001000
`define OP_RET 'b00001001
`define OP_MRA 'b00001010
`define OP_MVI 'b00001011
`define OP_MLR 'b00001100
`define OP_MMDR 'b00001101
`define OP_MRR 'b00001110
`define OP_OUTPUT 'b00001111
`define OP_STORE_WORD 'b00010000
`define OP_LOAD_WORD 'b00010001
`define OP_XOR 'b00010010
`define OP_SDY 'b00010011
`define OP_HALT 'b11111111

`endif
"""

# load opcodes 

opcodes = {}

for l in opcodes_vh.replace( "`ifndef _opcodes_vh_", "").replace("`define _opcodes_vh_", "").replace("`endif", "").split( "\n"):
    if l.replace( "\n", "" ):
        ( keyword, opcode, value) = l.replace( "\n", "" ).split( " " )
        opcodes[ int( value.replace("'b", ""), 2 ) ] = opcode[3:]

two_operand_opcodes = [
    "ADD",
    "SUB",
    "MULTIPLY",
    "AND",
    "OR",
    "XOR",
    "MVI"
]

memory_operand_opcodes = [
    "STORE_WORD",
    "LOAD_WORD"
]

one_operand_opcodes = [
    "SROP1",
    "SLOP1",
    "NEGOP1",
    "MRA",
    "MLR",
    "MMDR",
    "MRR"
]

constk_operand_opcodes = [
    "JMP"
]
zero_operand_opcodes = [
    "RET",
    "OUTPUT",
    "SDY",
    "HALT"
]

def main():
    # command line arguments
    parser = argparse.ArgumentParser(
            prog = "decompile_mest_prorgam.py",
            description = "convert a binary mest program into our simple asm" )

    parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
    #parser.add_argument('-c', '--comments', action='store_true', default=False, 
    #        help="append the original command as a comment to the end of each line (not the default behavior)")
    parser.add_argument('-o', '--output-file',
            help="the output file to write the new program to. If not specified, prints to stdout instead" )

    args = parser.parse_args()

    pline_e = "\n";

    # Open our outputfile
    fout = open( args.output_file, "w") if args.output_file else stdout 

    for l in fileinput.input(files=args.files if len(args.files) > 0 else ('-',)):
        l = re.sub('\/\/.*', '', l )
        l = l.strip().split("_")
        if l:
           
            opcode = opcodes[int( l[0], 2 )]
            constk = int(l[1],2)
            op1 = int(l[2],2)
            op2 = int(l[3],2)
            mem = int( l[2]+l[3], 2)

            if opcode in ( two_operand_opcodes + memory_operand_opcodes + one_operand_opcodes + constk_operand_opcodes + zero_operand_opcodes):
    
                if opcode in two_operand_opcodes:
                    fout.write( f"{opcode} {op1} {op2}\n" )
                elif opcode in memory_operand_opcodes:
                    fout.write( f"{opcode} {mem}\n" )
                elif opcode in one_operand_opcodes:
                    fout.write( f"{opcode} {op1}\n")
                elif opcode in constk_operand_opcodes:
                    fout.write( f"{opcode} {constk}\n")
                elif opcode in zero_operand_opcodes:
                    fout.write( f"{opcode}\n" )

if __name__ == "__main__":
    main()
