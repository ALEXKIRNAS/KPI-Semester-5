import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;

public class DataBlock implements Serializable {
    private final int maxBlockSize = 8;
    private boolean isUsed;
    private String data;
    private ArrayList<Integer> links;
    private HashMap<String, Integer> listOfLinks;

    public DataBlock() {
        listOfLinks = new HashMap<String, Integer>();
        links = new ArrayList<Integer>();
        data = "";
        for (int i = 0; i < maxBlockSize; i++) {
            data += " ";
        }
    }

    public String getData() {
        return data;
    }

    public void setData(String data) {
        this.data = data;
    }

    public void setData(int id) {
        if (links.size() < maxBlockSize) {
            links.add(id);
        } else {
            System.out.println("You can't add more links in this block");
        }
    }

    public ArrayList<Integer> getDataLinks() {
        return links;
    }

    public HashMap<String, Integer> getDataList() {
        return listOfLinks;
    }

    public void setData(String name, int id) {
        if (listOfLinks.size() < maxBlockSize) {
            listOfLinks.put(name, id);
        } else {
            System.out.println("You can't add more links in this block");
        }
    }

    public int getMaxBlockSize() {
        return maxBlockSize;
    }

    public boolean isUsed() {
        return isUsed;
    }

    public void setUsed(boolean used) {
        isUsed = used;
    }
}
