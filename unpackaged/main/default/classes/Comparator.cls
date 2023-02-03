/******************Modification History*****************************************
 * Punith          2022-10-07          LSP-452**
 * ****************************************************************************/
/** @DESC : Comparator is a generic class to provide different types of Sorting Mechanisms for a Object.
  *         Concrete Class has to implements its compare method.
  */
public inherited sharing abstract class Comparator {
    public abstract Integer compare(Object o1, Object o2);
    public static void sort(List<Object> values, Comparator comp) {
        //  Obtain the list type of values
        List<Object> temp = values.clone();
        temp.clear();
        //  Helper class for sorting using Comparable
        List<Arrange> tempValues = new List<Arrange>();
        for(Object value: values) {
            tempValues.add(new Arrange(comp, value));
        }
        //  Perform sort
        tempValues.sort();
        //  Extract values back into temp list
        for(Arrange arrange: tempValues) {
            temp.add(arrange.value);
        }
        //  And set the list to the new, sorted order
        values.clear();
        values.addAll(temp);
    }
    //  Simply calls Comparator when asked.
    class Arrange implements Comparable {
        Comparator method;
        Object value;
        Arrange(Comparator comp, Object val) {
            method = comp;
            value = val;
        }
        public Integer compareTo(Object compareTo) {
            return method.compare(value, ((Arrange)compareTo).value);
        }
    }
}