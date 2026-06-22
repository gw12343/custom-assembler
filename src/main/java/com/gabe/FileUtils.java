package com.gabe;

import java.io.PrintWriter;
import java.util.HashMap;

public class FileUtils {
    public static void writePlainHexFile(String[] data, String path){
        if(path == null)
            return;
        StringBuilder out = new StringBuilder("v3.0 hex words plain\n");
        int i = 0;
        for (String datum : data) {
            if (i != 0) {
                out.append(" ");
            }
            out.append(datum);
            i++;
            if (i >= 8) {
                out.append("\n");
                i = 0;
            }
        }

        try (PrintWriter o = new PrintWriter(path)) {
            o.println(out);
        }catch (Exception e){
            System.err.println("Failed to save file! " + path + "\n" + e.getMessage());
        }
    }

    public static void writeHexMemFile(String[] data, String path){
        if(path == null)
            return;
        StringBuilder out = new StringBuilder();
        for (String datum : data) {
            out.append(datum);
            out.append("\n");
        }
        out.setLength(out.length() - 1);

        try (PrintWriter o = new PrintWriter(path)) {
            o.println(out);
        }catch (Exception e){
            System.err.println("Failed to save file! " + path + "\n" + e.getMessage());
        }
    }

    public static void writeTable(HashMap<String, String> table, String path){
        if(path == null)
            return;

        StringBuilder out = new StringBuilder("in_cmb[11..0] |          mc_o[28..0]         \n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n");

        for(HashMap.Entry<String, String> entry : table.entrySet()){
            out
                .append(entry.getKey())
                .append("  | ")
                .append(entry.getValue())
                .append("\n");
        }

        try (PrintWriter o = new PrintWriter(path)) {
            o.println(out);
        }catch (Exception e){
            System.err.println("Failed to save file! " + path + "\n" + e.getMessage());
        }
    }
}
