import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from feynman import Diagram

# Bhabha s-channel and t-channel
fig = plt.figure(figsize=(8, 3))
ax = fig.add_axes([0,0,1,1], frameon=False)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)

# s-channel
fd = Diagram(ax)
# s-channel vertices
in_e = fd.vertex(xy=(0.05, 0.8), marker='')
in_p = fd.vertex(xy=(0.05, 0.2), marker='')
v_left = fd.vertex(xy=(0.2, 0.5))
v_right = fd.vertex(xy=(0.4, 0.5))
out_e = fd.vertex(xy=(0.55, 0.8), marker='')
out_p = fd.vertex(xy=(0.55, 0.2), marker='')

l1 = fd.line(in_e, v_left, arrow=True)
l1.text(r"$e^-(p)$", fontsize=14, y=-.1)

l2 = fd.line(in_p, v_left, arrow=False)
fd.line(v_left, in_p, arrow=True) # Draw arrow pointing left to indicate positron
# Actually feynman package: arrow=False, add arrow manually or just use arrow=True on reverse
fd.text(in_p.xy[0], in_p.xy[1]-0.05, r"$e^+(k)$", fontsize=14)

l3 = fd.line(v_left, v_right, style='wiggly')

l4 = fd.line(v_right, out_e, arrow=True)
fd.text(out_e.xy[0], out_e.xy[1]+0.05, r"$e^-(p')$", fontsize=14)

l5 = fd.line(out_p, v_right, arrow=True) # Positron moving out = arrow pointing towards vertex
fd.text(out_p.xy[0], out_p.xy[1]-0.05, r"$e^+(k')$", fontsize=14)

fd.text(0.3, 0.35, "(s-channel)", fontsize=14)

# t-channel
in_e2 = fd.vertex(xy=(0.65, 0.8), marker='')
in_p2 = fd.vertex(xy=(0.65, 0.2), marker='')
v_top = fd.vertex(xy=(0.8, 0.7))
v_bot = fd.vertex(xy=(0.8, 0.3))
out_e2 = fd.vertex(xy=(0.95, 0.8), marker='')
out_p2 = fd.vertex(xy=(0.95, 0.2), marker='')

fd.line(in_e2, v_top, arrow=True)
fd.text(in_e2.xy[0], in_e2.xy[1]+0.05, r"$e^-(p)$", fontsize=14)

fd.line(in_p2, v_bot, arrow=False)
fd.line(v_bot, in_p2, arrow=True)
fd.text(in_p2.xy[0], in_p2.xy[1]-0.05, r"$e^+(k)$", fontsize=14)

fd.line(v_top, v_bot, style='wiggly')

fd.line(v_top, out_e2, arrow=True)
fd.text(out_e2.xy[0], out_e2.xy[1]+0.05, r"$e^-(p')$", fontsize=14)

fd.line(out_p2, v_bot, arrow=True)
fd.text(out_p2.xy[0], out_p2.xy[1]-0.05, r"$e^+(k')$", fontsize=14)

fd.text(0.9, 0.5, "(t-channel)", fontsize=14)

fd.plot()
plt.savefig('_assets/bhabha.svg', transparent=True)
plt.close()

# Compton Scattering s-channel and u-channel
fig = plt.figure(figsize=(8, 3))
ax = fig.add_axes([0,0,1,1], frameon=False)
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)

fd2 = Diagram(ax)
# s-channel Compton
# e-(p) and gamma(k) in -> e- propagator -> e-(p') and gamma(k') out
in_e = fd2.vertex(xy=(0.05, 0.8), marker='')
in_g = fd2.vertex(xy=(0.05, 0.2), marker='')
v_left = fd2.vertex(xy=(0.2, 0.5))
v_right = fd2.vertex(xy=(0.4, 0.5))
out_e = fd2.vertex(xy=(0.55, 0.8), marker='')
out_g = fd2.vertex(xy=(0.55, 0.2), marker='')

fd2.line(in_e, v_left, arrow=True)
fd2.text(in_e.xy[0], in_e.xy[1]+0.05, r"$e^-(p)$", fontsize=14)

fd2.line(in_g, v_left, style='wiggly')
fd2.text(in_g.xy[0], in_g.xy[1]-0.05, r"$\gamma(k)$", fontsize=14)

fd2.line(v_left, v_right, arrow=True) # electron propagator

fd2.line(v_right, out_e, arrow=True)
fd2.text(out_e.xy[0], out_e.xy[1]+0.05, r"$e^-(p')$", fontsize=14)

fd2.line(v_right, out_g, style='wiggly')
fd2.text(out_g.xy[0], out_g.xy[1]-0.05, r"$\gamma(k')$", fontsize=14)

fd2.text(0.3, 0.35, "(s-channel)", fontsize=14)

# u-channel Compton
# e-(p) -> emits gamma(k') -> propagates -> absorbs gamma(k) -> e-(p')
# Actually looking at the ASCII:
# e-(p)  in top left, gamma(k') out top right from same vertex?
# Wait, u-channel: e- in, emits gamma out. Then propagates. Then absorbs gamma in.
in_e2 = fd2.vertex(xy=(0.65, 0.8), marker='')
in_g2 = fd2.vertex(xy=(0.65, 0.2), marker='')
v_top = fd2.vertex(xy=(0.8, 0.7))
v_bot = fd2.vertex(xy=(0.8, 0.3))
out_e2 = fd2.vertex(xy=(0.95, 0.2), marker='') # Note: e- out is bottom right in ASCII
out_g2 = fd2.vertex(xy=(0.95, 0.8), marker='') # gamma out is top right in ASCII

fd2.line(in_e2, v_top, arrow=True)
fd2.text(in_e2.xy[0], in_e2.xy[1]+0.05, r"$e^-(p)$", fontsize=14)

fd2.line(in_g2, v_bot, style='wiggly')
fd2.text(in_g2.xy[0], in_g2.xy[1]-0.05, r"$\gamma(k)$", fontsize=14)

fd2.line(v_top, v_bot, arrow=True) # electron propagator

fd2.line(v_top, out_g2, style='wiggly')
fd2.text(out_g2.xy[0], out_g2.xy[1]+0.05, r"$\gamma(k')$", fontsize=14)

fd2.line(v_bot, out_e2, arrow=True)
fd2.text(out_e2.xy[0], out_e2.xy[1]-0.05, r"$e^-(p')$", fontsize=14)

fd2.text(0.9, 0.5, "(u-channel)", fontsize=14)

fd2.plot()
plt.savefig('_assets/compton.svg', transparent=True)
plt.close()
