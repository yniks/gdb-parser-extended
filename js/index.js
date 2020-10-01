"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GdbParser = void 0;
/**
 * Internal Handle to the PEGJS parser.
 * This Parser is expected to to be generated from PEGjs or atleast exports
 * @see Parser like interface.
 */
const Parser = require("./parser");
class GdbParserClass {
    /**
     * Shall be used to get basic syntatic sanity of the C or c++ code
     * @param input c source code
     */
    checkCStatements(input) { return Parser.parse(input, { startRule: 'STATEMENTS' }); }
    /**
     * Shall be used to parse output of the custom `Ptypes` gdb command
     * @param input custom `Ptypes` gdb command output
     */
    consoleParsePtypes(input) { return Parser.parse(input, { startRule: 'PTYPES' }); }
    /**
     * Shall be used to parse the output of `info macros` or `info macro %macro` command
     * @param input output of `info macros` or `info macro %macro` command
     */
    consoleParseMacros(input) { return Parser.parse(input, { startRule: 'MACROS' }); }
    /**
     * Shall be used to parse output of `info types` or `info type %type` command
     * @param input output of `info types` or `info type %type` command
     */
    consoleParseTypes(input) { return Parser.parse(input, { startRule: 'TYPES' }); }
    /**
     * Shall be used to parse output of any GDB machine interpreter (GDB/MI) command.
     * @param input full output sequence of any GDB/MI command
     */
    parseMIoutput(input) { return Parser.parse(input, { startRule: 'GDBMI_OUTPUT' }); }
    /**
     * Shall be used to parse a single record of a gdb output.
     * Can be useful in cases where GDB/MI output is being received over a stream
     *
     * @param input single record of a gdb output
     */
    parseMIrecord(input) { return Parser.parse(input, { startRule: 'GDBMI_RECORD' }); }
}
var GdbParser = new GdbParserClass;
exports.GdbParser = GdbParser;
//# sourceMappingURL=index.js.map