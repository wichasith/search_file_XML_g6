import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import java.util.regex.*; 
import java.lang.Object;
import java.security.MessageDigestSpi;
import java.security.MessageDigest;
import java.io.InputStream;
import java.io.FileInputStream;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat; // inuse
import java.util.regex.*;


void setup() {
  size(500,75);
  frameRate(60);
  String root = "/home/fulla/Desktop/year3term1/processing/search_file_xml/animal";
  XML xmlWrite,xmlRead;
  xmlWrite = new XML("path");
  String filename ="save.xml";
  String search ;
  //search = "cit";
  //search = "6f5902ac237024bdd0c176cb93063dc4";
  //search = "10/15/2021 11:20:35";
  search = "5.461 KB";
  xmlRead = loadXML(filename);
  ArrayList<String> temp = new ArrayList<String>();
  saveDirectoryXML(root,search,xmlWrite);
  println("key : " +search);
  searchDirectoryXML(xmlRead,search,temp,root,Pattern.compile(search, Pattern.CASE_INSENSITIVE));

}
  void saveDirectoryXML(String dir,String search,XML xml) {
    File file = new File(dir);
    if (file.isDirectory() && !file.isHidden()) {
      String names[] = file.list();
      XML newChild = xml.addChild("Folder");
      String[] split = split(dir,"/");
      newChild.setString("name",split[split.length-1]);
      for(int i = 0; i < names.length;i++) {
        saveDirectoryXML(dir+"/"+names[i],search,newChild);
      }
    }else {
      if(!file.isHidden()){
        SimpleDateFormat date = new SimpleDateFormat("MM/dd/yyyy HH:mm:ss");
        String checksum = "";
        String size = str(file.length()/1000.0)+" KB";
        try{
          MessageDigest md5Digest = MessageDigest.getInstance("MD5");
          checksum = getFileChecksum(md5Digest, file);
        }catch(IOException e ){}
        catch(NoSuchAlgorithmException e){}
        String[] split = split(dir,"/");
        XML newChild = xml.addChild("File");
        newChild.setContent(split[split.length-1]);
        newChild.setString("md5", checksum);
        newChild.setString("size",size);
        newChild.setString("date",date.format(file.lastModified()));        
      }    
    }                    
    saveXML(xml, "save.xml");
    exit();
  }
  
  void searchDirectoryXML(XML xml,String search,ArrayList<String> temp,String root,Pattern pattern) {
    CheckWay way;
    String[] Vowels = { "a" , "e" , "i" , "o" , "u" } ;
    XML[] children = xml.getChildren();
    for (int i = 0; i < children.length; i++) {
      way = new CheckWay(children[i],search);
      if(children[i].hasChildren()) {
        if(children[i].getName().equals("Folder")){ 
          if(children[i].getString("name").equals(search)) {
            String[] path = getPath(children[i],temp);
            printPath(path,root);
            println("/" +children[i].getString("name") + "\n" + "folder = "+ children[i].getString("name") ) ; 
          }
          else if(pattern.matcher(children[i].getString("name")).find() ){
            String[] path = getPath(children[i],temp);
            printPath(path,root);
            println("/" +children[i].getString("name")+ "\n" + "folder = "+ children[i].getString("name") ) ; 
          }
          else if (true){
            String lowersearch = search.toLowerCase();
            for(int a = 0 ; a < Vowels.length ; a++){
              String newSearch = lowersearch.replace(Vowels[a],".");
              if(Pattern.matches(newSearch, children[i].getString("name").toLowerCase())){
                String[] path = getPath(children[i],temp);
                printPath(path,root);
                println("/" +children[i].getString("name")+  "\n" + "folder = "+ children[i].getString("name") ) ; 
              }
            }
          }
          searchDirectoryXML(children[i],search,temp,root,pattern);    
        }
        else if(children[i].getName().equals("File")){
          if(children[i].getContent().equals(search) || way.isTrue()) {
            temp.add(children[i].getContent());
            String[] path = getPath(children[i],temp);
            printPath(path,root);
            println("");
            way.printWay();
            println( "File = "+ children[i].getContent() ) ;
            temp.clear();
          }
          else if(pattern.matcher(children[i].getContent()).find() ){
            temp.add(children[i].getContent());
            String[] path = getPath(children[i],temp);
            printPath(path,root);
            println("");
            way.printWay();
            println( "File = "+ children[i].getContent() ) ;
            temp.clear();
          }
          else if (true) {
          String lowersearch = search.toLowerCase();
          for(int a = 0 ; a < Vowels.length ; a++){
              String newSearch = lowersearch.replace(Vowels[a],".");
              if(Pattern.matches(newSearch, children[i].getContent().toLowerCase())){
                temp.add(children[i].getContent());
                String[] path = getPath(children[i],temp);
                printPath(path,root);
                println("");
                way.printWay();
                println( "File = "+ children[i].getContent() ) ;
                temp.clear();
              }
          }
          }
       }
     }
    }
   }
    
  
  
  
  String[] getPath(XML path,ArrayList<String> pathArr) {
    XML temp = path.getParent();
    if(temp.getName().equals("Folder")){
      pathArr.add(temp.getString("name"));
      getPath(temp,pathArr);      
    }
    return convertToArrStr(pathArr);
    
  }
  
  void printPath(String[] temp,String root) {
    String[] list = reverse(temp);
    String[] path = split(root,"/");
    path = shorten(path);
    //print(path[0]);
    for(int i = 1; i < path.length ;i++) { print("/"+path[i]);}
    for(int i = 0;i < list.length;i++ ) {
      print("/"+list[i]);
    }
  }
  
  private static String getFileChecksum(MessageDigest digest, File file) throws IOException
{
    //Get file input stream for reading the file content
    FileInputStream fis = new FileInputStream(file);
     
    //Create byte array to read data in chunks
    byte[] byteArray = new byte[1024];
    int bytesCount = 0; 
      
    //Read file data and update in message digest
    while ((bytesCount = fis.read(byteArray)) != -1) {
        digest.update(byteArray, 0, bytesCount);
    };
     
    //close the stream; We don't need it now.
    fis.close();
     
    //Get the hash's bytes
    byte[] bytes = digest.digest();
     
    //This bytes[] has bytes in decimal format;
    //Convert it to hexadecimal format
    StringBuilder sb = new StringBuilder();
    for(int i=0; i< bytes.length ;i++)
    {
        sb.append(Integer.toString((bytes[i] & 0xff) + 0x100, 16).substring(1));
    }
     
    //return complete hash
   return sb.toString();
} 


String[] convertToArrStr(ArrayList<String> temp) {
  String[] list = new String[temp.size()];
  for(int index = 0; index < temp.size(); index++) {
    list[index] = temp.get(index);
  }
  return list;
}

class CheckWay {
  String search;
  XML child;
  int way;
  
  CheckWay(XML child,String search){
    this.search = search;
    this.child = child;

  }
  
  boolean isTrue(){

    if(child.getString("md5").equals(search)){ way = 1; return true; }
    if(child.getString("date").equals(search)){ way = 2; return true; }
    if(child.getString("size").equals(search)){ way = 3; return true; }
    return false;
  }
  
  void printWay() {
    if(way == 1){print(" " + "md5 = " + child.getString("md5") + " ");}
    else if(way == 2){print(" " + "date = " + child.getString("date")+ " ");}
    else if(way == 3){print(" " + "size = " + child.getString("size")+ " ");}
  }
}
