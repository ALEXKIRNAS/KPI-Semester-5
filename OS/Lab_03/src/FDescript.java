import java.io.Serializable;
import java.util.ArrayList;

public class FDescript implements Serializable {
    private final int maxNumberOfLinks = 5;
    private boolean isFolder;
    private int size;
    private ArrayList<Integer> links;

    public FDescript(boolean isFolder, int numberOfLinks, int size) {
        this.isFolder = isFolder;
        this.size = size;
        links = new ArrayList<Integer>();
    }

    public ArrayList<Integer> getLinks() {
        return links;
    }

    public void addLink(int link) {
        links.add(link);
    }

    public int getMaxNumberOfLinks() {
        return maxNumberOfLinks;
    }

    public boolean isFolder() {
        return isFolder;
    }

    public void setFolder(boolean folder) {
        isFolder = folder;
    }

    public int getNumberOfLinks() {
        return links.size();
    }

    public int getSize() {
        return size;
    }

    public void setSize(int size) {
        this.size = size;
    }
}
