public class PrefixTree {
    private PTNode root;
    private int size;  // should be number of leaves
    public PTNode getRoot ( ) {return root;}
    public void setRoot (PTNode node) {root = node;}
    public int getSize ( ) {return size;}
    public PrefixTree ( ) {root = new PTNode (""); size = 0;}
    
    public boolean contains (String w) {
    // returns true if calling tree contains a node for the string w
    // this means that the path of w's letters leads to a node,
    // rather than anything to do with the "elem" fields of the nodes
    // assumes that w is a string of lower-case letters, else returns false
    	PTNode tempRoot = root;
		for(int i = 0; i<w.length(); i++) {
			char c = w.charAt(i);
			if(tempRoot.getChild(c) == null) 
				return false;            
			else tempRoot = tempRoot.getChild(c);
		}
		return(tempRoot.getElem().equals(w));
//        PTNode current = root;
//        for (int i = 0; i < w.length( ); i++) {
//            if ((w.charAt(i) < 'a') || (w.charAt(i) > 'z')) return false;
//            if (current.getChild (w.charAt(i)) == null) return false;
//            current = current.getChild (w.charAt(i));}
//        return true;}
    }

    public void addString (String w) { 
        PTNode tempRoot = root;
        for(int i = 0; i<w.length();i++) {
            if(tempRoot.getChild(w.charAt(i)) == null) 
            	if(i==w.length()-1)
            		tempRoot.setChild(w.charAt(i), w.substring(0,i+1)); 
            	else tempRoot.setChild(w.charAt(i), "");
            
            tempRoot = tempRoot.getChild(w.charAt(i));
        }
        size++;
    }
}