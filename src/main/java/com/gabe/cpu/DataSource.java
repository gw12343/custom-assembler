package com.gabe.cpu;

/**
 * Enum representing various data sources that can be used in CPU instructions.
 *
 * <p>
 * The data sources specify where the data for a particular operation
 * is coming from, such as an operand or an offset.
 * </p>
 *
 * <ul>
 *   <li>{@link #EMPTY} - No data source specified.</li>
 *   <li>{@link #OPERAND1} - The first operand as the data source.</li>
 *   <li>{@link #OPERAND2} - The second operand as the data source.</li>
 *   <li>{@link #OPERAND1_OFFSET} - The offset from the first operand. For example, if the first operand is "[sp+12]", this would access 12.</li>
 *   <li>{@link #OPERAND2_OFFSET} - The offset from the second operand. For example, if the second operand is "[r2-8]", this would access -8.</li>
 * </ul>
 *
 * @author Gabriel West
 * @Date 7/1/2024
 */
public enum DataSource {
    /**
     * No data source specified.
     */
    EMPTY,

    /**
     * The first operand as the data source.
     */
    OPERAND1,

    /**
     * The second operand as the data source.
     */
    OPERAND2,

    /**
     * The offset from the first operand. For example, if the first operand is "[r6+12]", this would access 12.
     */
    OPERAND1_OFFSET,

    /**
     * The offset from the second operand. For example, if the second operand is "[sp+8]", this would access 8.
     */
    OPERAND2_OFFSET
}