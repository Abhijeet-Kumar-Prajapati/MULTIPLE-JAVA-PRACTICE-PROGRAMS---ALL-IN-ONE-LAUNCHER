import java.util.PriorityQueue;
import java.util.Comparator;

class HuffmanNode {
    int frequency;
    char character;
    HuffmanNode left, right;

    HuffmanNode(char character, int frequency) {
        this.character = character;
        this.frequency = frequency;
        this.left = null;
        this.right = null;
    }
}

class NodeComparator implements Comparator<HuffmanNode> {
    public int compare(HuffmanNode node1, HuffmanNode node2) {
        return node1.frequency - node2.frequency;
    }
}

public class HuffmanCoding {
    public static void printCodes(HuffmanNode root, String code) {
        if (root.left == null && root.right == null && Character.isLetter(root.character)) {
            System.out.println(root.character + ":" + code);
            return;
        }
        if (root.left != null) {
            printCodes(root.left, code + "0");
        }
        if (root.right != null) {
            printCodes(root.right, code + "1");
        }
    }

    public static void buildHuffmanTree(char[] charArray, int[] charFreq) {
        PriorityQueue<HuffmanNode> queue = new PriorityQueue<>(new NodeComparator());
        for (int i = 0; i < charArray.length; i++) {
            queue.add(new HuffmanNode(charArray[i], charFreq[i]));
        }
        while (queue.size() > 1) {
            HuffmanNode left = queue.poll();
            HuffmanNode right = queue.poll();
            HuffmanNode newNode = new HuffmanNode('-', left.frequency + right.frequency);
            newNode.left = left;
            newNode.right = right;
            queue.add(newNode);
        }
        HuffmanNode root = queue.poll();
        System.out.println("Character Huffman Codes");
        printCodes(root, " ");
    }

    public static void main(String[] args) {
        char[] charArray = { 'a', 'b', 'c', 'd', 'e', 'f' };
        int[] charFreq = { 5, 9, 12, 13, 16, 45 };
        buildHuffmanTree(charArray, charFreq);
    }
}