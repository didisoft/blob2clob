/**
* BLOB2CLOB
*
* Description: A PL/SQL routine that converts a BLOB field into CLOB selecting the correct UTF encoding based on the BOM header 
*
* Params
*  p_blob IN BLOB input blob field
*
* Returns 
*  converted CLOB
*
* DidiSoft Inc 2020. MIT License
*/
create or replace function blob2clob(p_blob in blob)
return CLOB 
is
  -- Byte order marks for UTF-8, UTF-16LE and UTF-16BE
  C_BOM_UTF8     constant raw(3) := hextoraw('EFBBBF');
  C_BOM_UTF16LE  constant raw(2) := hextoraw('FFFE');
  C_BOM_UTF16BE  constant raw(2) := hextoraw('FEFF');

  CSID_UTF8 constant integer := 873;
  CSID_UTF16LE constant integer := 2002;
  CSID_UTF16BE constant integer := 2000;

  l_dest_offset  integer := 1;
  l_src_offset   integer := 1;
  l_encoding     integer := CSID_UTF8;
  l_lang_context number := dbms_lob.default_lang_ctx;
  
  l_bom          raw(3);
  l_warning      integer;
  l_start_pos    integer := 1;  
  
  l_result CLOB;
begin

  l_bom := dbms_lob.substr(p_blob, 3);  
  if l_bom = C_BOM_UTF8 then    
    l_encoding := CSID_UTF8;    
    l_start_pos := 4;
  else    
    case utl_raw.substr(l_bom, 1, 2)    
     when C_BOM_UTF16LE then
      l_encoding := CSID_UTF16LE;    
      l_start_pos := 3;
     when C_BOM_UTF16BE then
      l_encoding := CSID_UTF16BE;      
      l_start_pos := 3;      
     else    
      l_encoding := CSID_UTF8;          
    end case;    
  end if;
  
  DBMS_LOB.createtemporary(l_result, false);

  DBMS_LOB.converttoclob(l_result,
   p_blob,
   DBMS_LOB.GETLENGTH(p_blob)-l_start_pos+1,
   l_dest_offset,
   l_start_pos,
   l_encoding,
   l_lang_context,
   l_warning);

   return l_result;
end;   
