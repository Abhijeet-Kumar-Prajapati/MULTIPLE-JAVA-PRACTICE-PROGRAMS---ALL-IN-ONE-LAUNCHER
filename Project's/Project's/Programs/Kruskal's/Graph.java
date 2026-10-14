import java.util.*;

// Class to represent an edge in the graph
class Edge implements Comparable<Edge> {
    int src, dest, weight;

    // Comparator function used for sorting edges based on their weight
    public int compareTo(Edge compareEdge) {
        return this.weight - compareEdge.weight;
    }
}

// Class to represent a subset for union-find
class Subset {
    int parent, rank;
}

// Main class to represent a graph
class Graph {
    int vertices, edges; // Number of vertices and edges
    Edge edge[]; // Collection of all edges

    // Constructor
    Graph(int v, int e) {
        vertices = v;
        edges = e;
        edge = new Edge[e];
        for (int i = 0; i < e; ++i) {
            edge[i] = new Edge();
        }
    }

    // Function to find set of an element i (uses path compression technique)
    int find(Subset subsets[], int i) {
        if (subsets[i].parent != i)
            subsets[i].parent = find(subsets, subsets[i].parent);
        return subsets[i].parent;
    }

    // A function that does union of two sets of x and y (uses union by rank)
    void union(Subset subsets[], int x, int y) {
        int rootX = find(subsets, x);
        int rootY = find(subsets, y);

        // Attach smaller rank tree under root of the higher rank tree
        if (subsets[rootX].rank < subsets[rootY].rank)
            subsets[rootX].parent = rootY;
        else if (subsets[rootX].rank > subsets[rootY].rank)
            subsets[rootY].parent = rootX;
        else {
            subsets[rootY].parent = rootX;
            subsets[rootX].rank++;
        }
    }

    // Function to construct MST using Kruskal's algorithm
    void kruskalMST() {
        Edge result[] = new Edge[vertices]; // Store the resultant MST
        int e = 0; // Index for the result[]
        int i = 0; // Index used to pick the next edge
        for (i = 0; i < vertices; ++i)
            result[i] = new Edge();

        // Step 1: Sort all the edges in non-decreasing order of their weight
        Arrays.sort(edge);

        // Allocate memory for creating subsets
        Subset subsets[] = new Subset[vertices];
        for (i = 0; i < vertices; ++i)
            subsets[i] = new Subset();

        // Create subsets with single elements
        for (int v = 0; v < vertices; ++v) {
            subsets[v].parent = v;
            subsets[v].rank = 0;
        }

        i = 0; // Initial index of sorted edges

        // Number of edges to be taken is equal to V-1
        while (e < vertices - 1) {
            // Step 2: Pick the smallest edge and increment the index for next iteration
            Edge nextEdge = edge[i++];

            int x = find(subsets, nextEdge.src);
            int y = find(subsets, nextEdge.dest);

            // If including this edge does not form a cycle, include it in the result
            // and increment the index of the result for the next edge
            if (x != y) {
                result[e++] = nextEdge;
                union(subsets, x, y);
            }
        }

        // Print the constructed MST
        System.out.println("Following are the edges in the constructed MST:");
        int minimumCost = 0;
        for (i = 0; i < e; ++i) {
            System.out.println(result[i].src + " -- " + result[i].dest + " == " + result[i].weight);
            minimumCost += result[i].weight;
        }
        System.out.println("Minimum Cost Spanning Tree: " + minimumCost);
    }

    // Driver Code
    public static void main(String[] args) {
        int vertices = 4; // Number of vertices in the graph
        int edges = 5; // Number of edges in the graph
        Graph graph = new Graph(vertices, edges);

        // Add edge 0-1
        graph.edge[0].src = 0;
        graph.edge[0].dest = 1;
        graph.edge[0].weight = 10;

        // Add edge 0-2
        graph.edge[1].src = 0;
        graph.edge[1].dest = 2;
        graph.edge[1].weight = 6;

        // Add edge 0-3
        graph.edge[2].src = 0;
        graph.edge[2].dest = 3;
        graph.edge[2].weight = 5;

        // Add edge 1-3
        graph.edge[3].src = 1;
        graph.edge[3].dest = 3;
        graph.edge[3].weight = 15;

        // Add edge 2-3
        graph.edge[4].src = 2;
        graph.edge[4].dest = 3;
        graph.edge[4].weight = 4;

        // Function call
        graph.kruskalMST();
    }
}
