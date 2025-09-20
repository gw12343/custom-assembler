package com.gabe.assembler;

import org.apache.commons.lang3.StringUtils;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Tokenizer {
    /**
     * Tokenizes the input string
     * @return a {@code List<Token>} containing the tokens
     */
    public static List<Token> tokenize(String program, boolean eof){
        List<Token> tokens = new ArrayList<>();
        String s = program;
        int lineNum = 1;
        int charNum = 0;

        while(!s.isEmpty()) {
            boolean consumed = false;
            token_search:
            for (TokenType t : TokenType.values()) {
                for (String regex : t.getRegexen()) {
                    Pattern pattern = Pattern.compile(regex);
                    Matcher matcher = pattern.matcher(s);
                    if (matcher.find()) {
                        String match = matcher.group(0);
                        String removed = s.substring(0, match.length());

                        int matches = StringUtils.countMatches(removed, "\n");
                        lineNum += matches;
                        if(matches > 0) charNum = 0;

                        for(int i = removed.length() - 1; i >= 0; i--) {
                            if(removed.charAt(i) != '\n'){
                                charNum++;
                            }else{
                                break;
                            }
                        }

                        s = s.substring(match.length());
                        consumed = true;
                        switch (t){
                            case EMPTY -> {
                                break token_search;
                            }
                            case NUMBER -> {
                                double d;
                                if(match.startsWith("$")){
                                    d = Long.parseLong(match.substring(1), 16);
                                }else if(match.startsWith("%")){
                                    d = Integer.parseInt(match.substring(1), 2);
                                }else {
                                    d = Integer.parseInt(match);
                                }
                                tokens.add(new Token(t, match, d, lineNum, charNum));
                                break token_search;
                            }
                            case STRING -> {
                                String val = match.substring(1,match.length()-1);
                                val = val.replaceAll("\\\\\\\"", "\"");
                                val = val.replaceAll("\\\\n", "\n");
                                tokens.add(new Token(t, match, val, lineNum, charNum));
                            }
                            case CHAR -> {
                                Double d;
                                char c = match.charAt(1);
                                d = (int)c + 0.0;
                                tokens.add(new Token(TokenType.HASH, match, d, lineNum, charNum));
                                tokens.add(new Token(TokenType.NUMBER, match, d, lineNum, charNum));
                            }
                            default -> {
                                tokens.add(new Token(t, match, null, lineNum, charNum));
                                break token_search;
                            }
                        }
                    }
                }
            }

            if(!consumed){
                String lexeme = s.substring(0, 1);
                throw new RuntimeException("Invalid token: '" +lexeme+"'");
            }
        }

        if(eof)
            tokens.add(new Token(TokenType.EOF, "", null, lineNum, charNum));
        return tokens;
    }
}
