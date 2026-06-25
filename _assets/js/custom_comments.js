import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getAuth, signInWithPopup, GoogleAuthProvider, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
import { getFirestore, collection, addDoc, query, where, orderBy, getDocs, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-firestore.js";

// ==========================================
// !!! FIREBASE CONFIGURATION REQUIRED !!!
// ==========================================
// Replace this block with the config from your Firebase Project Settings
const firebaseConfig = {
  apiKey: "AIzaSyCJhRZkoUFU0IPBPSTClUiHtOwmQNvsIlM",
  authDomain: "azazaya-comments.firebaseapp.com",
  projectId: "azazaya-comments",
  storageBucket: "azazaya-comments.firebasestorage.app",
  messagingSenderId: "607384871535",
  appId: "1:607384871535:web:cd73794fe91782c0e5e39a",
  measurementId: "G-EGMZV7X4XL"
};

// Initialize HTML Skeleton
const container = document.getElementById("custom-comments-container");
if (container) {
  container.innerHTML = `
    <div id="comments-header">
      <h3>Discussion</h3>
      <div id="auth-section">
        <button id="google-login-btn" class="comment-btn"><i class="fab fa-google"></i> Login to Comment</button>
        <div id="user-info" style="display: none;">
          <span id="user-name"></span>
          <button id="logout-btn" class="comment-btn-small">Logout</button>
        </div>
      </div>
    </div>
    
    <div id="comment-input-section" style="display: none;">
      <textarea id="comment-text" placeholder="Write your comment here... You can use LaTeX math like $$ E = mc^2 $$"></textarea>
      <button id="submit-comment-btn" class="comment-btn">Post Comment</button>
    </div>
    
    <div id="comments-list">
      <p>Loading comments...</p>
    </div>
  `;
}

// Initialize Firebase
let app, auth, db;
try {
    app = initializeApp(firebaseConfig);
    auth = getAuth(app);
    db = getFirestore(app);
} catch (e) {
    if (container) {
        document.getElementById("comments-list").innerHTML = `<p style="color:red; font-weight:bold;">Firebase Configuration is missing! Please set up your Firebase project and paste the keys in _assets/js/custom_comments.js.</p>`;
    }
}

const loginBtn = document.getElementById('google-login-btn');
const logoutBtn = document.getElementById('logout-btn');
const userInfo = document.getElementById('user-info');
const userNameSpan = document.getElementById('user-name');
const inputSection = document.getElementById('comment-input-section');
const submitBtn = document.getElementById('submit-comment-btn');
const commentText = document.getElementById('comment-text');
const commentsList = document.getElementById('comments-list');

const currentPath = window.location.pathname;

if (auth && loginBtn) {
    // Listen for Auth state
    onAuthStateChanged(auth, (user) => {
      if (user) {
        loginBtn.style.display = 'none';
        userInfo.style.display = 'flex';
        inputSection.style.display = 'block';
        userNameSpan.textContent = user.displayName;
      } else {
        loginBtn.style.display = 'block';
        userInfo.style.display = 'none';
        inputSection.style.display = 'none';
      }
    });

    // Login
    loginBtn.addEventListener('click', async () => {
      const provider = new GoogleAuthProvider();
      try {
        await signInWithPopup(auth, provider);
      } catch (error) {
        console.error("Login failed", error);
      }
    });

    // Logout
    logoutBtn.addEventListener('click', async () => {
      await signOut(auth);
    });

    // Post Comment
    submitBtn.addEventListener('click', async () => {
      const text = commentText.value.trim();
      if (!text) return;
      
      const user = auth.currentUser;
      if (!user) return;
      
      submitBtn.disabled = true;
      submitBtn.textContent = 'Posting...';
      
      try {
        await addDoc(collection(db, "comments"), {
          path: currentPath,
          author: user.displayName,
          uid: user.uid,
          text: text,
          timestamp: serverTimestamp()
        });
        commentText.value = '';
        fetchComments(); // Reload comments
      } catch (e) {
        console.error("Error adding document: ", e);
        alert("Failed to post comment. Ensure Firestore Security Rules allow writing.");
      }
      
      submitBtn.disabled = false;
      submitBtn.textContent = 'Post Comment';
    });
}

// Fetch Comments
async function fetchComments() {
    if (!db || !commentsList) return;
    
    try {
        const q = query(collection(db, "comments"), where("path", "==", currentPath), orderBy("timestamp", "desc"));
        const querySnapshot = await getDocs(q);
        
        commentsList.innerHTML = '';
        if (querySnapshot.empty) {
            commentsList.innerHTML = '<p>No comments yet. Be the first to start the discussion!</p>';
            return;
        }
        
        querySnapshot.forEach((doc) => {
            const data = doc.data();
            const date = data.timestamp ? data.timestamp.toDate().toLocaleDateString() : 'Just now';
            
            const commentDiv = document.createElement('div');
            commentDiv.className = 'comment-item';
            
            commentDiv.innerHTML = `
                <div class="comment-meta">
                    <span class="comment-author">${data.author}</span>
                    <span class="comment-date">${date}</span>
                </div>
                <div class="comment-body">${escapeHTML(data.text)}</div>
            `;
            
            commentsList.appendChild(commentDiv);
        });
        
        // Render LaTeX dynamically inside the comments!
        if (typeof renderMathInElement !== 'undefined') {
            renderMathInElement(commentsList, {
                delimiters: [
                    {left: '$$', right: '$$', display: true},
                    {left: '$', right: '$', display: false},
                    {left: '\\(', right: '\\)', display: false},
                    {left: '\\[', right: '\\]', display: true}
                ]
            });
        }
    } catch (e) {
        console.error("Failed to fetch comments", e);
        if (e.message && e.message.includes("requires an index")) {
            commentsList.innerHTML = '<p style="color:orange">Database indexing required! Check browser console for the Firestore link to create the index.</p>';
        } else {
            commentsList.innerHTML = '<p>Failed to connect to Database. Please configure Firebase keys.</p>';
        }
    }
}

// Security HTML escape
function escapeHTML(str) {
    return str.replace(/[&<>'"]/g, 
        tag => ({
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            "'": '&#39;',
            '"': '&quot;'
        }[tag])
    );
}

// Initial fetch
if (container) {
    fetchComments();
}
