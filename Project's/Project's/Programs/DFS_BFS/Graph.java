import java.util.*;

class Graph {
    private int vertices;
    private LinkedList<Integer> adjList[];

    Graph(int v) {
        vertices = v;
        adjList = new LinkedList[v];
        for (int i = 0; i < v; i++) {
            adjList[i] = new LinkedList<>();
        }
    }

    void addEdge(int v, int w) {
        adjList[v].add(w);
    }

    void DFSUtil(int v, boolean visited[]) {
        visited[v] = true;
        System.out.println(v + " ");
        for (int n : adjList[v]) {
            if (!visited[n]) {
                DFSUtil(n, visited);
            }
        }
    }

    void DFS(int v) {
        boolean visited[] = new boolean[vertices];
        DFSUtil(v, visited);
    }

    void BFS(int start) {
        boolean visited[] = new boolean[vertices];
        LinkedList<Integer> queue = new LinkedList<>();
        visited[start] = true;
        queue.add(start);
        while (queue.size() != 0) {
            int s = queue.poll();
            System.out.println(s + " ");
            for (int n : adjList[s]) {
                if (!visited[n]) {
                    visited[n] = true;
                    queue.add(n);
                }
            }
        }
    }

    public static void main(String[] args) {
        Graph g = new Graph(6);
        g.addEdge(0, 1);
        g.addEdge(0, 2);
        g.addEdge(1, 3);
        g.addEdge(1, 4);
        g.addEdge(2, 4);
        g.addEdge(3, 5);
        g.addEdge(4, 5);
        System.out.println("Depth First Search(Starting from vertex 0):");
        g.DFS(0);
        System.out.println("\nBreadth First Search(Starting from vertex 0):");
        g.BFS(0);
    }
}