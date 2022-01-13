-- draw setup
    lg.setDefaultFilter('nearest')
    lg.setLineWidth(8)
    lg.setLineStyle('rough')
    
function draw()
    bg(0.4,0.8,0.8)
    fg(0.2,0.4,0.9)
    --rect('fill',0,0,leftedge,24*36)
    fg(0.8,0.2,0.4)
    --rect('fill',leftedge+6*96,0,28*36-(leftedge+6*96),24*36)
    local r,g,b=HSLtoRGB((t*0.012)%1,0.9,0.9)
    local r2,g2,b2=HSLtoRGB((t2*0.012)%1,0.2,0.2)
    t2=t2+1
    fg(r,g,b)
    lg.setFont(arcadef4)
    lg.push()
    lg.rotate(math.pi*0.4)
    lg.print('Batch-3',60-60,-120-40-20+40)
    lg.pop()
    lg.setFont(arcadef2)
    --lg.print('hello world!')
    lg.push()
    lg.rotate(math.pi*0.1)
    lg.print('Score',40+40+140+80,300+300)
    if score>999999 then score=999999 end
    shown_score=shown_score+(score-shown_score)*0.2
    lg.print(fmt('%.6d',math.floor(shown_score+0.5)),40+40+140+80-64,300+300+64)
    lg.pop()
    lg.push()
    lg.rotate(-math.pi*0.1)
    if level~='inf' then
    lg.print(fmt('Level %d',level),-240+40+30-12,24*36-32-64-140-40-10+10)
    else
    lg.print('Level',-240+40+30-12,24*36-32-64-140-40-10+10)
    lg.rotate(math.pi/2)
    lg.print(8,-20+80+300+300-64+6+10,-20-40-16)
    end
    lg.pop()

    lg.setFont(arcadef1)
    lg.push()
    lg.translate(leftedge+6*96+24-6,12*36+64)
    lg.rotate(-math.pi/4)
    if level~='inf' then
    lg.print(fmt('Swaps: %d/%d',old_prog or #program,level+2),-20-4,0)
    else
    lg.print(fmt('Swaps: %d/%d',old_prog or #program,7),-20-4,0)
    end
    lg.pop()
    lg.push()
    lg.translate(leftedge+6*96+24-6,12*36+34+34+8+64-32)
    lg.rotate(math.pi/4)
    if level~='inf' then
    lg.print(fmt('Combo: %d/%d',longest_combo,level+2),20-4,0)
    else
    lg.print(fmt('Combo: %d/%d',longest_combo,7),20-4,0)
    end
    lg.pop()
    lg.setLineWidth(8)

    if (type(level)=='number' and #program==level+2) or (level=='inf' and #program==7) then
        lg.draw(images.play,leftedge+6*96+24+12,24*36-128)
    end
    fg(1,1,1)
    for h=1,math.min(hearts,16) do
        local img=images.heart
        if (h*2-t*0.2)%12<3 then img=images.heartwhiteness end
        local hx=leftedge+6*96+24+24+8
        if hearts>8 then hx=hx-24 end
        local hy=24+(h-1)*48
        if h>8 then hx=hx+48; hy=24+(h-8-1)*48 end
        lg.draw(img,hx+sin(h+t*0.2)*4,hy)
    end
    for k,j in pairs(jelloes) do
        local jx,jy=strpos(k)
        local jello=images[j.color]
        if j.flash and j.flash%20<10 then jello=images.whiteness end
        lg.draw(jello,j.x,j.y,0,1-0.05+cos((t+jx*2+jy*2)*0.2)*0.05,1-0.05+sin((t+jx*2+jy*2)*0.3)*0.05)
        local img=images.face1
        if j.color=='green' then img=images.face2 end
        if j.color=='purple' then img=images.face3 end
        if j.color=='red' then img=images.face4 end
        if jello~=images.whiteness then lg.draw(img,j.x+cos((t+jx*2+jy*2)*0.2)*8,j.y+sin((t+jx*2+jy*2)*0.3)*6) end
    end
    --fg(0.9,0.9,0.9)
    
    fg(r,g,b)
    --[[if action then
        local kx,ky=strpos(action[1])
        rect('line',leftedge+kx*96-8,ky*96-8,96+2*8,96+2*8)
    end]]
    lg.setFont(arcadef5)
    for i,v in ipairs(program) do
        local sx,sy=strpos(v[1])
        local ex,ey=strpos(v[2])
        v.sx=v.sx or leftedge+sx*96+48; v.sy=v.sy or sy*96+48
        v.ex=v.ex or leftedge+ex*96+48; v.ey=v.ey or ey*96+48
        if v.tgty2 then
            v.acc=v.acc or 0
            v.sy=v.sy+v.acc
            v.ey=v.ey+v.acc
            v.acc=v.acc+0.4
            if v.sy>=v.tgty2 then v.sy=v.tgty2; v.ey=v.tgty2+(ey-sy)*96; v.tgty2=nil; v.acc=nil end
        end
        lg.line(v.sx,v.sy,v.ex,v.ey)
        --lg.print(v.i,v.sx,v.sy)
        local cx,cy=(v.ex+v.sx)/2, (v.ey+v.sy)/2
        fg(0.4,0.8,0.8)
        lg.circle('fill',cx,cy,20+6)
        fg(r,g,b)
        lg.circle('line',cx,cy,20+6)
        lg.print(v.i,cx-arcadef5:getWidth(v.i)/2,cy-arcadef5:getHeight(v.i)/2)
    end

    if love.update==plan then
    if action then
        local jx,jy=strpos(action[1])
        lg.draw(images.select,leftedge+jx*96-16,jy*96-16)
        lg.draw(images.select,leftedge+jx*96+96+16,jy*96-16,math.pi/2)
        lg.draw(images.select,leftedge+jx*96+96+16,jy*96+96+16,math.pi)
        lg.draw(images.select,leftedge+jx*96-16,jy*96+96+16,math.pi/2*3)
    end
    for k,j in pairs(jelloes) do
        local jx,jy=strpos(k)
        if AABB(mox,moy,1,1,leftedge+jx*96,jy*96,96,96) and ((type(level)=='number' and #program<level+2) or (level=='inf' and #program<7)) then
            if not action then
            lg.draw(images.select,leftedge+jx*96-16+t%16,jy*96-16+t%16)
            lg.draw(images.select,leftedge+jx*96+96+16-t%16,jy*96-16+t%16,math.pi/2)
            lg.draw(images.select,leftedge+jx*96+96+16-t%16,jy*96+96+16-t%16,math.pi)
            lg.draw(images.select,leftedge+jx*96-16+t%16,jy*96+96+16-t%16,math.pi/2*3)
            else
            local kx,ky=strpos(action[1])
            if k~=action[1] and k==posstr(kx+1,ky) or k==posstr(kx-1,ky) or k==posstr(kx,ky+1) or k==posstr(kx,ky-1) then
            lg.draw(images.select,leftedge+jx*96-16+t%16,jy*96-16+t%16)
            lg.draw(images.select,leftedge+jx*96+96+16-t%16,jy*96-16+t%16,math.pi/2)
            lg.draw(images.select,leftedge+jx*96+96+16-t%16,jy*96+96+16-t%16,math.pi)
            lg.draw(images.select,leftedge+jx*96-16+t%16,jy*96+96+16-t%16,math.pi/2*3)
            end
            end
        end
    end
    end

    --lg.print(fmt('Combo: %d',cur_combo),0,96)
    for i=#combo_ind,1,-1 do
        local c=combo_ind[i]
        fg(r,g,b)
        if c.msg=='Game over' or c.msg=='Combo end' then fg(r2,b2,g2) end
        if c.t>=30 or c.msg=='Combo end' then --sync with flash time
        if c.t==30 and c.msg~='Combo end' and c.msg~='Game over' then audio.sparkle:stop(); audio.sparkle:setPitch(1+(cur_combo-2)*1/12); audio.sparkle:play() end
        c.l=c.l or 0
        c.l2=c.l2 or 0
        lg.setLineWidth(24)
        lg.line(c.x+cos(c.a-math.pi/2)*64+cos(c.a-math.pi)*c.l2,c.y+sin(c.a-math.pi/2)*64+sin(c.a-math.pi)*c.l2,c.x+cos(c.a-math.pi/2)*64+cos(c.a-math.pi)*c.l,c.y+sin(c.a-math.pi/2)*64+sin(c.a-math.pi)*c.l)
        lg.line(c.x+cos(c.a+math.pi/2)*64+cos(c.a-math.pi)*c.l2,c.y+sin(c.a+math.pi/2)*64+sin(c.a-math.pi)*c.l2,c.x+cos(c.a+math.pi/2)*64+cos(c.a-math.pi)*c.l,c.y+sin(c.a+math.pi/2)*64+sin(c.a-math.pi)*c.l)
        if c.l<1200 then c.l=c.l+16 end
        if c.t>=90 and c.msg~='Game over' then c.l2=c.l2+16 end
        if c.t>50 and (c.t<90+20 or c.msg=='Game over') then
        lg.push()
        local cx,cy=cos(c.a-math.pi)*16*36,sin(c.a-math.pi)*16*36
        if c.a<math.pi/2 or c.a>=3*(math.pi/2) then cx,cy=cos(c.a-math.pi)*22*36,sin(c.a-math.pi)*22*36 end
        lg.translate(c.x+cx+cos(c.a-math.pi/2)*64,c.y+cy+sin(c.a-math.pi/2)*64)
        local rot=c.a
        if c.a>=math.pi/2 and c.a<3*(math.pi/2) then 
            rot=c.a-math.pi; lg.rotate(rot); lg.translate(-300,-100-40+8) --lg.translate(-(c.x+cos(c.a-math.pi)*16*36+cos(c.a-math.pi/2)*64),-(c.y+sin(c.a-math.pi)*16*36+sin(c.a-math.pi/2)*64)); lg.rotate(rot); lg.translate(0,-300)--lg.translate(-(c.x+cos(c.a-math.pi)*16*36+cos(c.a-math.pi/2)*64),-(c.y+sin(c.a-math.pi)*16*36+sin(c.a-math.pi/2)*64)) 
        else
        lg.rotate(rot)
        end
        lg.setFont(arcadef3)
        lg.print(c.msg,0,0)
        lg.pop()
        end
        end
        if c.t>=200 and c.msg~='Game over' then rem(combo_ind,i) end
        c.t=c.t+1
    end

    lg.setLineWidth(12)
    if love.update==dialogue or love.update==dialogue2 then
        fg(97/255,0,0,0.5)
        if diag_box.w>=30 then rect('fill',diag_box.x+30,diag_box.y+30,diag_box.w,diag_box.h) end
        fg(0.4,0.8,0.8,1)
        rect('fill',diag_box.x,diag_box.y,diag_box.w,diag_box.h)
        local r,g,b=HSLtoRGB((t2*0.012)%1,0.9,0.9)
        fg(r,g,b)
        rect('line',diag_box.x,diag_box.y,diag_box.w,diag_box.h)
        if math.abs(diag_box.tgth-diag_box.h)>1 then diag_box.h=diag_box.h+(diag_box.tgth-diag_box.h)*0.2
        else diag_box.x=diag_box.x+(diag_box.tgtx-diag_box.x)*0.2; diag_box.w=diag_box.w+(diag_box.tgtw-diag_box.w)*0.2 end
        if math.abs(diag_box.tgtw-diag_box.w)<1 then
            if love.update==dialogue then
            if t-sc_t==60 then audio.rising:stop(); audio.rising:play() end
            if t-sc_t>=60 then
                lg.setFont(arcadef1)
                local tx,ty=0,0
                for i=1,#('Longest\ncombo') do
                if i<t-sc_t-60 then
                local char=sub('Longest\ncombo',i,i)
                if char=='\n' then ty=ty+34; tx=arcadef1:getWidth('Longest')/2-arcadef1:getWidth('combo')/2 
                else
                lg.print(char,diag_box.x+24+tx,diag_box.y+diag_box.h-96+ty+sin(i+t*0.2)*4)
                tx=tx+arcadef1:getWidth(char)
                end
                end
                end
            end
            if t-sc_t==90 then
                audio.sparkle2:stop(); audio.sparkle2:play()
                starburst2(diag_box.x+24+48,diag_box.y+64,'yellow')
            end
            if t-sc_t>=90 then
                lg.setFont(arcadef2)
                lg.print(longest_combo,diag_box.x+24+48+14-arcadef2:getWidth(longest_combo)/2,diag_box.y+64)
            end
            if t-sc_t>=120 then
                lg.setFont(arcadef2)
                lg.print('-',diag_box.x+diag_box.w/3-48,diag_box.y+64)
            end
            if t-sc_t==135 then audio.rising:stop(); audio.rising:play() end
            if t-sc_t>=135 then
                lg.setFont(arcadef1)
                local tx,ty=0,0
                for i=1,#('Required\ncombo') do
                if i<t-sc_t-135 then
                local char=sub('Required\ncombo',i,i)
                if char=='\n' then ty=ty+34; tx=arcadef1:getWidth('Required')/2-arcadef1:getWidth('combo')/2
                else
                lg.print(char,diag_box.x+diag_box.w/2-80+tx,diag_box.y+diag_box.h-96+ty+sin(i+t*0.2)*4)
                tx=tx+arcadef1:getWidth(char)
                end
                end
                end
            end
            if t-sc_t==135+30 then
                audio.sparkle2:stop(); audio.sparkle2:play()
                starburst2(diag_box.x+diag_box.w/2-34,diag_box.y+64,'green')
            end
            if t-sc_t>=135+30 then
                lg.setFont(arcadef2)
                local c
                if type(level)=='number' then c=level+2
                else c=7 end
                lg.print(c,diag_box.x+diag_box.w/2-34,diag_box.y+64)
            end
            if t-sc_t>=135+30+30 then
                lg.setFont(arcadef2)
                lg.print('=',diag_box.x+diag_box.w/3*2-48,diag_box.y+64)
            end
            if t-sc_t==135+30+30+15 then
                audio.rising:stop(); audio.rising:play()
            end
            if t-sc_t>=135+30+30+15 then
                lg.setFont(arcadef1)
                local tx,ty=0,0
                for i=1,#('Hearts') do
                if i<t-sc_t-(135+30+30+15) then
                local char=sub('Hearts',i,i)
                if char=='\n' then ty=ty+34; tx=0 
                else
                lg.print(char,diag_box.x+diag_box.w/3*2+48+tx,diag_box.y+diag_box.h-96+ty+sin(i+t*0.2)*4)
                tx=tx+arcadef1:getWidth(char)
                end
                end
                end                
            end
            if t-sc_t==135+30+30+15+30 then
                audio.sparkle2:stop(); audio.sparkle2:play()
                local c
                if type(level)=='number' then c=level+2
                else c=7 end
                local msg=longest_combo-c
                if msg>0 then msg='+'..tostring(msg) end
                starburst2(diag_box.x+diag_box.w/3*2+34+34+34-arcadef2:getWidth(msg)/2,diag_box.y+64,'red')
            end
            if t-sc_t>=135+30+30+15+30 then
                lg.setFont(arcadef2)
                local c
                if type(level)=='number' then c=level+2
                else c=7 end
                local msg=longest_combo-c
                if msg>0 then msg='+'..tostring(msg) end
                lg.print(msg,diag_box.x+diag_box.w/3*2+34+34+34-arcadef2:getWidth(msg)/2,diag_box.y+64)
                fg(1,1,1)
                lg.draw(images.heart,diag_box.x+diag_box.w/3*2+34+34+34-arcadef2:getWidth(msg)/2+arcadef2:getWidth(msg),diag_box.y+64+24)
            end
            elseif love.update==dialogue2 then
                if t-sc_t>=60 then
                    local msg='Congratulations for beating all the\npractice levels! Now go for a high score!\n\nThis game was made by verysoftwares\nfor Juice Jam.'
                    lg.setFont(arcadef1)
                    local tx,ty=0,0
                    for i=1,#msg do
                    if i<t-sc_t-60 then
                    local char=sub(msg,i,i)
                    if char=='\n' then ty=ty+34; tx=0
                    else
                    lg.print(char,diag_box.x+24+tx,diag_box.y+80-30+ty+sin(i+t*0.2)*4)
                    tx=tx+arcadef1:getWidth(char)
                    end
                    end
                    end
                end
                if t-sc_t>=60+129 then
                end
            end
        end
    end

    fg(1,1,1)
    for i=#particles,1,-1 do
        local p=particles[i]
        p.j=p.j or i
        p.x=p.x+p.dx; p.y=p.y+p.dy
        local img=p.img
        if (p.j+t*0.2)%16<4 then
            img=images['whitenessstar'..tostring(p.i)]
        end
        lg.draw(img,p.x,p.y)
        p.dy=p.dy+0.4
        if p.y>24*36 then rem(particles,i) end
    end
    
end

function HSLtoRGB(h, s, l)
    if s == 0 then return l, l, l end
    local function to(p, q, t)
        if t < 0 then t = t + 1 end
        if t > 1 then t = t - 1 end
        if t < .16667 then return p + (q - p) * 6 * t end
        if t < .5 then return q end
        if t < .66667 then return p + (q - p) * (.66667 - t) * 6 end
        return p
    end
    local q = l < .5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    return to(p, q, h + .33334), to(p, q, h), to(p, q, h - .33334)
end

love.draw= draw

