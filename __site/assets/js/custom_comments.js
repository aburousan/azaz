import { initializeApp } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-app.js";
import { getAuth, signInWithPopup, signInWithRedirect, getRedirectResult, GoogleAuthProvider, onAuthStateChanged, signOut } from "https://www.gstatic.com/firebasejs/10.8.0/firebase-auth.js";
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

    // If we came back from a redirect-based login, finish it.
    getRedirectResult(auth).catch((error) => {
      if (error && error.code !== 'auth/no-auth-event') {
        console.error("Redirect login failed", error);
        showLoginError(error);
      }
    });

    // Login
    loginBtn.addEventListener('click', async () => {
      const provider = new GoogleAuthProvider();
      const original = loginBtn.innerHTML;
      loginBtn.disabled = true;
      loginBtn.innerHTML = '<i class="fab fa-google"></i> Signing in…';
      try {
        await signInWithPopup(auth, provider);
      } catch (error) {
        console.error("Popup login failed", error);
        // Popups are commonly blocked or unsupported (in-app browsers, some
        // mobile setups). Fall back to a full-page redirect in those cases.
        if (error && (error.code === 'auth/popup-blocked' ||
                      error.code === 'auth/popup-closed-by-user' ||
                      error.code === 'auth/cancelled-popup-request' ||
                      error.code === 'auth/operation-not-supported-in-this-environment')) {
          try {
            await signInWithRedirect(auth, provider);
            return; // page navigates away
          } catch (e2) {
            console.error("Redirect login failed", e2);
            showLoginError(e2);
          }
        } else {
          showLoginError(error);
        }
      } finally {
        loginBtn.disabled = false;
        loginBtn.innerHTML = original;
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

// Show a readable reason when Google sign-in fails, instead of failing
// silently. The single most common cause on a freshly deployed site is the
// live domain not being whitelisted in Firebase Auth → Settings →
// Authorized domains.
function showLoginError(error) {
  const code = (error && error.code) || '';
  let msg;
  switch (code) {
    case 'auth/unauthorized-domain':
      msg = "This site's domain isn't authorized for login yet. " +
            "Add it under Firebase Console → Authentication → Settings → " +
            "Authorized domains.";
      break;
    case 'auth/operation-not-allowed':
      msg = "Google sign-in isn't enabled. Turn it on under Firebase " +
            "Console → Authentication → Sign-in method.";
      break;
    case 'auth/configuration-not-found':
      msg = "Authentication isn't set up for this Firebase project yet. " +
            "In the Firebase Console: open Authentication → Get started, " +
            "then Sign-in method → enable Google, and add this site's " +
            "domain under Settings → Authorized domains.";
      break;
    case 'auth/popup-blocked':
      msg = "Your browser blocked the login popup. Please allow popups and " +
            "try again.";
      break;
    case 'auth/network-request-failed':
      msg = "Network error reaching Google sign-in. Check your connection " +
            "and try again.";
      break;
    default:
      msg = "Login failed" + (code ? " (" + code + ")" : "") +
            ". See the browser console for details.";
  }
  alert(msg);
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
