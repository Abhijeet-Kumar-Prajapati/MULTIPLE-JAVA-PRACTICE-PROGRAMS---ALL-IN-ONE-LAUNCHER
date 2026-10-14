import javax.swing.*;  
import java.awt.event.*;  // Import for event handling

public class EventHandlingDemo {  
    public static void main(String[] args) {  
        // Create a frame
        JFrame frame = new JFrame("Event Handling Example");  
        
        // Create a button
        JButton button = new JButton("Click Me");  
        button.setBounds(100, 100, 150, 50);  // Set the position and size of the button
        
        // Add an ActionListener to handle button click events
        button.addActionListener(new ActionListener() {  
            public void actionPerformed(ActionEvent e) {  
                // Code to be executed when the button is clicked
                JOptionPane.showMessageDialog(null, "Button Clicked!");  
            }  
        });  
        
        // Add the button to the frame
        frame.add(button);  
        
        // Frame properties
        frame.setSize(400, 400);  
        frame.setLayout(null);  
        frame.setVisible(true);  
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);  
    }  
}
