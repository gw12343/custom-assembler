package com.gabe.assembler;

import java.util.Arrays;

/**
 * Represents a token
 */
public enum TokenType {
    EMPTY("^\\s+", "^;.*"),
    // Single-character tokens.
    LEFT_BRAC("^[\\[]"),
    RIGHT_BRAC("^[\\]]"),

    COMMA("^[,]"),

    EQUAL("^="),
    HASH("^#"),
    MINUS("^[\\-]"),
    PLUS("^[+]"),

    COLON("^[:]"),
    SLASH("^[/]"),



    // Keywords.
    MNEMONICS("^(" + AssemblerMnemonic.getRegex() + ")(?![_a-zA-Z0-9])"),
    DIRECTIVES(AssemblerDirectives.getRegex() + "(?![_a-zA-Z0-9])"),


    // Literals.
    CHAR("^\\'(\\\\.|[^\\\"\\\\])\\'"),
    STRING("^\\\"(\\\\.|[^\\\"\\\\])*\\\""),
    NUMBER("^(\\$[0-9A-Fa-f]+|%[01]+|f\\d+(\\.\\d+)?|\\d+)"),
    IDENTIFIER("^[_a-zA-Z\\p{So}_]{1,31}[_a-zA-Z0-9\\p{So}_]{0,31}"),

    // End of File
    EOF;

    // List of regular expressions representing this token
    final String[] regexen;
    TokenType(String... regexen){
        //System.out.println(Arrays.toString(regexen));
        this.regexen = regexen;
    }

    public String[] getRegexen() {
        return regexen;
    }
}
