package com.gabe.assembler;

import java.util.Arrays;

public record OperationHeader(OperandType... locations) {
    @Override
    public String toString() {
        return Arrays.toString(locations);
    }

    @Override
    public boolean equals(Object obj) {
        if(!(obj instanceof OperationHeader o)) return false;

        return o.hashCode() == this.hashCode();
    }

    @Override
    public int hashCode() {
        // Random stuff, should be fine for now
        int x = 1;
        int o = 0;
        int i = 12;
        for (OperandType location : locations) {
            o += x * ((location == OperandType.LABEL ? OperandType.MEM : location).ordinal() + i);
            x *= 10;
            x ^= o;
            i++;
        }
        return o;
    }
}
