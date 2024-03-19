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

opcodes = {}

for l in opcodes_vh.replace( "`ifndef _opcodes_vh_", "").replace("`define _opcodes_vh_", "").replace("`endif", "").split( "\n"):
    if l.replace( "\n", "" ):
        ( keyword, opcode, value) = l.replace( "\n", "" ).split( " " )
        opcodes[opcode[3:]] = int( value.replace("'b", ""), 2 )

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
            prog = "parse_mest_prorgam.py",
            description = "convert a simple program to binary for verilog" )

    parser.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')
    parser.add_argument('-c', '--comments', action='store_true', default=False, 
            help="append the original command as a comment to the end of each line (not the default behavior)")
    parser.add_argument('-o', '--output-file',
            help="the output file to write the new program to. If not specified, prints to stdout instead" )

    args = parser.parse_args()

    pline_e = "\n";


    # Regex Parsers
    opcode_checker = re.compile( r'(?P<OPCODE>\w+)' )
    two_operands = re.compile( r'(?P<OPCODE>' + "|".join( [f"({o})" for o in two_operand_opcodes] ) + 
                              ')\s+(?P<OPERAND1>\d+)\s+(?P<OPERAND2>\d+)' ) 
    memory_operands = re.compile( r'(?P<OPCODE>' + "|".join( [f"({o})" for o in memory_operand_opcodes] ) + 
                              ')\s+(?P<OPERAND1>\d+)' ) 
    one_operand = re.compile( r'(?P<OPCODE>' + "|".join( [f"({o})" for o in one_operand_opcodes] ) + 
                              ')\s+(?P<OPERAND1>\d+)' )
    constk_operand = re.compile( r'(?P<OPCODE>' + "|".join( [f"({o})" for o in constk_operand_opcodes] ) + 
                              ')\s+(?P<CONSTK>\d+)' )
    zero_operand = re.compile( r'(?P<OPCODE>' + "|".join( [f"({o})" for o in zero_operand_opcodes] ) + ')$' )


    # Open our outputfile
    fout = open( args.output_file, "w") if args.output_file else stdout 

    for l in fileinput.input(files=args.files if len(args.files) > 0 else ('-',)):
        l = l.strip()
        if l:
            oc = opcode_checker.match(l)
            opcode = oc.group(1)
            
            if opcode in ( two_operand_opcodes + memory_operand_opcodes + one_operand_opcodes + constk_operand_opcodes + zero_operand_opcodes):
    
                if args.comments:
                    pline_e = f" // {l}\n";
                
                if opcode in two_operand_opcodes:
                    too = two_operands.match(l)
                    if too:
                        g = too.groupdict()
                        if not ( (int(g['OPERAND1'])  > 255 ) or (int( g['OPERAND2'] ) > 255) ):
                            fout.write( f"{opcodes[opcode]:08b}_{0:08b}_{int(g['OPERAND1']):08b}_{int(g['OPERAND2']):08b}{pline_e}")
                        else:
                            stderr.write(f"Error: operand greater than 8 bit int: {l}\n")
                    else:
                        stderr.write(f"malformed line for {l}\n")
                elif opcode in memory_operand_opcodes:
                    moo = memory_operands.match( l )
                    if moo:
                        g = moo.groupdict()
                        if not ( int(g['OPERAND1'] ) > 65535 ):

                            binary_address = f"{int(g['OPERAND1']):016b}"
                            fout.write( f"{opcodes[opcode]:08b}_{0:08b}_{binary_address[:8]}_{binary_address[8:]}{pline_e}" )
                        else:
                            stderr.write( "malformed line for{l}\n" )

                elif opcode in one_operand_opcodes:
                    ooo = one_operand.match(l)
                    if ooo:
                        g = ooo.groupdict()
                        if not (int(g['OPERAND1'])  > 255 ):
                            fout.write( f"{opcodes[opcode]:08b}_{0:08b}_{int(g['OPERAND1']):08b}_{0:08b}{pline_e}")
                        else:
                            stderr.write(f"Error: operand greater than 8 bit int: {l}\n")
                        
                    else:
                        stderr.write(f"malformed line for {l}\n")
                elif opcode in constk_operand_opcodes:
                    ckoo = constk_operand.match(l)
                    if ckoo:
                        g = ckoo.groupdict()
                        if not (int(g['CONSTK'])  > 255 ):
                            fout.write( f"{opcodes[opcode]:08b}_{int(g['CONSTK']):08b}_{0:08b}_{0:08b}{pline_e}")
                        else:
                            stderr.write(f"Error: constk greater than 8 bit int: {l}\n")
                    else:
                        stderr.write(f"malformed line for {l}\n")
                elif opcode in zero_operand_opcodes:
                    zoo = zero_operand.match(l)
                    if zoo:
                        fout.write( f"{opcodes[opcode]:08b}_{0:08b}_{0:08b}_{0:08b}{pline_e}")
                    else:
                        stderr.write(f"malformed line for {l}\n")

if __name__ == "__main__":
    main()
