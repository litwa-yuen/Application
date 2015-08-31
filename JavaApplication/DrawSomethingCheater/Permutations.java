import java.io.*;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.*;

public class Permutations {
	private  ArrayList<String> list = new ArrayList<String>();
	private PrefixTree vaildTree;
	public static void main(String args[]) throws Exception{

		new Permutations();
	} 

	public Permutations() throws IOException { }{

		vaildTree = new PrefixTree();
		String word = "";

		Data wordList = new Data ();
		while(wordList.hasNext()) {
			word = wordList.processLine();
			vaildTree.addString(word);
		}
		String str;
		System.out.println("Enter the initial string");
		BufferedReader br=new BufferedReader(new InputStreamReader(System.in));
		str=br.readLine();
		int b=str.length();
		System.out.println("length of word");
		int a = Integer.parseInt(br.readLine());
		System.out.println("Permutations are :");    
		generate("", str.substring(0, b), a);

	}
	public  void generate(String prefix, String elements, int k) throws MalformedURLException, IOException {
		if (k == 0) {
			permute("", prefix);
			return;
		}
		for (int i = 0; i < elements.length(); i++)
			generate(prefix + elements.charAt(i), elements.substring(i + 1), k - 1);
	}  


	public  void permute(String beginningString, String endingString) throws MalformedURLException, IOException {
		if (endingString.length() <= 1){
			findWord(beginningString + endingString);
		}
		else
			for (int i = 0; i < endingString.length(); i++) {
				try {
					String newString = endingString.substring(0, i) + endingString.substring(i + 1);

					permute(beginningString + endingString.charAt(i), newString);
				} catch (StringIndexOutOfBoundsException exception) {
					exception.printStackTrace();
				}
			}
	}
	private  void findWord(String word) throws MalformedURLException,IOException {

		if(vaildTree.contains(word))
			if(!list.contains(word)){
				list.add(word);
				System.out.println(word);
			}
				
			
		//***************ONLINE******************
		//		URL url;
		//		if(!allPossible.contains(word))
		//			allPossible.add(word);
		//		else return;
		//		//System.out.print("test word: "+word+" ");
		//
		//		url=new URL("http://dictionary.reference.com/browse/"+word+"?s=t");
		//		BufferedReader website;
		//		website=new BufferedReader(new InputStreamReader(url.openStream()));
		//		String line;
		//		line=website.readLine();
		//		boolean noSuchWord=false;
		//		//  System.out.println("find: "+find);
		//		while(line!=null){
		//			if(line.contains("<div id=\"sph\">")||
		//					line.contains("<div class=\"dym\"><span class=\"dyme\">")){
		//				noSuchWord=true;
		//				break;
		//			}
		//			line=website.readLine();
		//		}
		//		if((!noSuchWord)&&(!list.contains(word))){
		//			list.add(word);
		//			System.out.println(word);
		//		}
	}



}