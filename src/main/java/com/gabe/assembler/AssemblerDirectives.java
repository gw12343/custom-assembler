package com.gabe.assembler;

public enum AssemblerDirectives {
    RESW,
    ASCIIZ,
    ASCII;



    /**
     * Generates a regex pattern to match any directive in a case-insensitive manner.
     *
     * @return the regex pattern as a string
     */
    public static String getRegex(){
        StringBuilder s = new StringBuilder("^\\.(");
        for (AssemblerDirectives directives : AssemblerDirectives.values()) {
            s.append("(");
            // Allow upper or lower case for each character
            for(char c : directives.name().toCharArray()){
                s.append("[");
                s.append(Character.toUpperCase(c));
                s.append(Character.toLowerCase(c));
                s.append("]");
            }
            s.append(")").append("|");
        }
        return s.deleteCharAt(s.length() - 1).append(")").toString();
    }
}
