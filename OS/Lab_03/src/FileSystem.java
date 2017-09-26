import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;

public class FileSystem implements Serializable {
    private final int numberOfBlocks = 8;
    private final int maxFileCount = 4;
    private DataBlock[] dataBlocks;
    private FDescript folder;
    private int fileCount;
    private HashMap<Integer, FDescript> fileDescriptors;
    private ArrayList<Integer> openedFiles;

    public FileSystem() {
        folder = new FDescript(true, 1, 0);
        dataBlocks = new DataBlock[numberOfBlocks];
        fileCount = 0;
        for (int i = 0; i < dataBlocks.length; i++) {
            dataBlocks[i] = new DataBlock();
        }
        fileDescriptors = new HashMap<Integer, FDescript>();
        openedFiles = new ArrayList<Integer>();
    }

    public ArrayList<Integer> getOpenedFiles() {
        return openedFiles;
    }

    public HashMap<Integer, FDescript> getFileDescriptors() {
        return fileDescriptors;
    }

    public DataBlock[] getDataBlocks() {
        return dataBlocks;
    }

    public int getMaxFileCount() {
        return maxFileCount;
    }

    public FDescript getFolder() {
        return folder;
    }

    public int getFileCount() {
        return fileCount;
    }

    public void setFileCount(int fileCount) {
        this.fileCount = fileCount;
    }
}
