public class PTNode {
    private String elem;
    private PTNode [ ] child = new PTNode [26];
    public String getElem ( ) {return elem;}
    public void setElem (String w) {elem = w;}
    public PTNode getChild (char ch) {return child[ch - 'a'];}
    public void setChild (char ch, String w) {child[ch - 'a'] = new PTNode (w);}
    public PTNode (String w) {elem = w;}}