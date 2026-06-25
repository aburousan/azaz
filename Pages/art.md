~~~
<style>
  /* Soft, classic "page" background color that is easy on the eyes */
  body, .page, .page__inner-wrap, .page__content, .archive, #main {
    background-color: #fdfbf7 !important;
    color: #2c3e50 !important;
  }
  
  /* Match the masthead to the soft page color */
  .masthead {
    background-color: #fdfbf7 !important;
    border-bottom: 1px solid #eaeaea !important;
  }
  
  /* Elegant, classic title styling */
  h1#my-gallery {
    text-align: center;
    font-size: 3.5rem !important;
    font-weight: 900 !important;
    text-transform: uppercase;
    letter-spacing: 8px;
    color: #2c3e50 !important;
    margin-top: 20px;
    margin-bottom: 40px !important;
  }
  
  /* Classic, elegant back button */
  .back-btn {
    display: block;
    width: max-content;
    margin: 0 auto 20px auto;
    padding: 10px 25px;
    background: transparent;
    color: #2c3e50;
    border: 2px solid #2c3e50;
    border-radius: 30px;
    text-decoration: none;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 2px;
    transition: all 0.3s ease;
    cursor: pointer;
  }
  .back-btn:hover {
    background: #2c3e50;
    color: #fdfbf7;
    box-shadow: 0 5px 15px rgba(44, 62, 80, 0.2);
    transform: scale(1.05);
  }
</style>
~~~

# My Gallery

~~~
<button class="back-btn" onclick="window.history.back()">&#9664; Return</button>
~~~\\
{{art_carousel}}

{{comments}}
