ANY=GDBMI_RECORD/GDBMI_OUTPUT/TYPES/MACROS/PTYPES/STATEMENTS
TYPES= files:(File)+ {return files;}
File
  = "File" [\ ]+ filename:FileName __
  lines:(line:lineNumber? blank type:typeName __?	{return {line,type};})*
  { return {File:filename,types:lines.filter(item=>item.line)};}
 
typeName=name:[^\n;]+ ";"?  { return name.join("");}
FileName
  = name:[a-zA-Z0-9\.]+ ":" { return name.join("");}

lineNumber=line:[0-9]+':' {return Number(line.join(""))}


blank=[\t]+
__
 = [\n]
 
 /////////////////// parse output of info macros
MACROS = macros:MACRO+ {return {macros};}
MACRO
	="Defined at " definedat:LOCATION _n 
    useddat:("  included at " path:LOCATION _n {return path})*
    def:MACRODEF _n?
    {return {definedat,useddat,def}}
   
LOCATION
	= file:[^:]+ ":" line:[0-9]+ {return {file:file.join(''),line:Number(line.join(''))}}

C_IDENTIFIER
	= [A-Za-z_][A-Za-z0-9_]* {return text()}
MACRODEF
	= "#define" _ id:C_IDENTIFIER _ value:[^\n]* {return {id,value:value.join('')}}

_
	= [ \t]+
_n
	= [\n]+
    
    
 ///////////////scan output ptypes "sad" "sadas"
PTYPES =  ptypes:PType+  EOF {return ptypes}
PType= "type = " def:(!(EOF/"type =") val:.    {return val;} )+ {return {Type:def.join('')};}
EOF=!.

/////// PRECHECK CODE FOR VERY SIMPLE SYTAX ERROR
STATEMENTS= result:STATEMENT 
// 	!{ return result.search(/[\=\,\>\<]$/)>-1 }
     { return {type:'checkCStatement',valid:!!result} }
STATEMENT=(((('(' STATEMENT ')')/'()')
 	/(('{' STATEMENT '}') / '{}')
    /(('[' STATEMENT ']') / '[]')
    /(("'" [^']* "'")/"''")
    /(('"' [^"]* '"')/'""')
    /([^\(\)\{\}\[\]\"\']))
    !([\=\,\>\<] EOF)
    )* {return text()}
 /////// PARSE GDMI commands
GDBMI_RECORD=out_of_band_record / result_record / endOfoutput / GARBAGE
GDBMI_OUTPUT =out_of_band_records:( out_of_band_record )*  result_record:result_record end:endOfoutput {return [...out_of_band_records,result_record,end]}
endOfoutput="(gdb) " nl {return {type:'sequencebreak'}}
result_record = token:token  "^" result_class:result_class results:( "," result:result {return result} )* nl  {return{token,type:'result_record',class:result_class,...Object.fromEntries(results)}}

out_of_band_record =async_record / stream_record

async_record = exec_async_output / status_async_output / notify_async_output

exec_async_output = token:token  "*" async_output:async_output nl {return{token,type:'notify_async_output',...async_output}}

status_async_output = token:token  "+" async_output:async_output nl {return {token,type:'notify_async_output',...async_output}}

notify_async_output = token:token  "=" async_output:async_output nl {return {token,type:'notify_async_output',...async_output}}

async_output = async_class:async_class results:( "," result:result {return result})* 
		{
        return {
        	class:async_class,
        	results:Object.fromEntries(results)
        	}
        }

result_class ="done" / "running" / "connected" / "error" / "exit"

async_class =IDENTIFIER //"stopped" //others (where others will be added depending on the needs—this is still in development).

result =variable:variable "=" value:value {return [variable,value]}

variable =IDENTIFIER

value =const / tuple / list 

const =c_string 

tuple =("{}" {return {}})/  ("{" result:result results:( "," _result:result {return _result} )* "}"
    	{
        	return Object.fromEntries([result,...results])
           })
list =
	("[]" {return []} )/
	("[" value:value values:( "," _value:value {return _value})* "]"
    	{return [value,...values]}) /
    ("[" result:result results:( "," _result:result {return _result} )* "]"
    	{
        	return Object.fromEntries([result,...results])
           })
stream_record =console_stream_output / target_stream_output / log_stream_output

console_stream_output ="~" c_line:c_string nl {return {type:'console_stream_output',c_line}}

target_stream_output ="@"  c_line:c_string nl {return {type:'target_stream_output',c_line}}

log_stream_output ="&"  c_line:c_string nl {return {type:'log_stream_output',c_line}}

nl =CR / CR_LF

CR="\n"
CR_LF='\r\n'
token =[0-9]* {return text()}
IDENTIFIER=[a-zA-Z\-]+ {return text()}
c_string='"' ( !'"' ('\\"'/.))* '"' {return JSON.parse(text())}
GARBAGE = .* {return{type:"garbage-error",text: text()}}