# Feynman diagrams for the full QED example: tree, then one loop.
import sys, os
sys.path.insert(0, os.path.expanduser("~/Coding/sage/feynsage"))
from feynsage import *
from feynsage.models import QED
from feynsage.diagram_plot import draw_diagrams

OUT = os.path.expanduser("~/Coding/julia/azaz/_assets/Physics/blogs/feynsage")
PREVIEW = os.environ.get("FS_PREVIEW")
os.makedirs(OUT, exist_ok=True)
if PREVIEW: os.makedirs(PREVIEW, exist_ok=True)

def save(fig, name):
    fig.savefig(os.path.join(OUT, name), transparent=True, bbox_inches="tight")
    if PREVIEW:
        fig.savefig(os.path.join(PREVIEW, name.replace(".svg", ".png")), dpi=130,
                    facecolor="white", bbox_inches="tight")
    print("wrote", name)

P = process('e- e+ -> mu- mu+', model=QED(), massless=['e', 'mu'])

f = draw_diagrams(P.diagrams, ncols=1, size=2.6)
save(f, "qed_tree.svg")

L = P.loop_diagrams()
print("loop diagrams:", len(L))
f = draw_diagrams(L, ncols=4, size=2.3)
save(f, "qed_oneloop.svg")
