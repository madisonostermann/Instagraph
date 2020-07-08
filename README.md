# Instagraph

Instagraph is an iOS application that automatically produces visualizations of tabular data. 
A user simply points their phone at printed or digital tabular data, or uploads an image of tabular data from their photo library; Instagraph decides the best graphical representation of the data (bar chart, line graph, etc.) then displays the results in physical space using augmented reality. 
These graphs may be manipulated by the user to zoom, identify precise values, change graph type, and so on.

Instagraph - to our knowledge - is the only data visualization tool so far that visualizes tabular data from the user’s environment (e.g. from a book or screen) without requiring the user to manually enter data into a device.

The data extraction component involves importing and cropping the image, preparing the image for OCR, and recognizing and sorting the extracted text.
After importing and cropping the original image, a focused yet flawed image is passed to the image preparation phase. 
Various image manipulations done in OpenCV result in a perspective-corrected, doctored version of the cropped image ​without table lines​. 
This image is passed to the text recognition (done with Tesseract OCR) and sorting step, which produces a 2D array of data extracted from the table, with each subarray representing a column from the data table. 
The 2D array is then used as the input for the automatic visualization component.

The automatic visualization part of the application takes this 2D array and analyzes the content to determine what types of graphs will represent the data in a way that makes sense. 
For example, a table with a column for months and a column for temperature probably makes the most sense represented as a line graph so that you can quickly gauge the change in temperature over time. 
After determining what types of graphs make sense to represent the data, the program attempts to map parts of the table to the appropriate properties of various graph models (e.g. axis labels or graph title). 
These properties can then be passed to our visualization code to produce graphs on the user’s screen.

# Demos
Bar Chart Visualization: https://www.youtube.com/watch?v=n56lA2_Rc4Y&feature=emb_logo
Line Graph Visualization: https://www.youtube.com/watch?v=WF4Gai-JpKY&feature=emb_logo
Interactive Value Bar: https://www.youtube.com/watch?v=pT0dG35hkLQ&feature=emb_logo
