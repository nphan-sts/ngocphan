public with sharing class ObjecIterator implements Iterator<CustomObjectWrapper>{

    private List<CustomObjectWrapper> objectList;
    private Integer currentIndex;

    public ObjecIterator(List<CustomObjectWrapper> objectList) {
        this.objectList = objectList;
        this.currentIndex = 0;
    }
    public Boolean hasNext(){ 
        return currentIndex < objectList.size();
    } 

    public CustomObjectWrapper next(){
        if(hasNext()) {
            return objectList[currentIndex++];
        } else {
            throw new NoSuchElementException('Iterator has no more elements.');
        }
    } 
}