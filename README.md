# blob2clob
PL/SQL routine that converts textual data from a BLOB field into CLOB with internal check for UTF the data encoding

Sample usage:

l_clob := BLOB2CLOB(p_blob);
