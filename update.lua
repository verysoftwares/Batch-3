jelloes={}

leftedge=28*36/2-3*96+2*36-24

score=0
shown_score=0

level=1
hearts=3

function strpos(pos)
    local delim=string.find(pos,':')
    local x=sub(pos,1,delim-1)
    local y=sub(pos,delim+1)
    --important tonumber calls
    --Lua will handle a string+number addition until it doesn't
    return tonumber(x),tonumber(y)
end

function posstr(x,y)
    return fmt('%d:%d',x,y)
end

function match3(k,test)
    local jx,jy=strpos(k)
    local j=jelloes[k]
    local horiz={k}
    i=1
    while jelloes[posstr(jx+i,jy)] and jelloes[posstr(jx+i,jy)].color==j.color do
        ins(horiz,posstr(jx+i,jy))
        i=i+1
    end
    i=-1
    while jelloes[posstr(jx+i,jy)] and jelloes[posstr(jx+i,jy)].color==j.color do
        ins(horiz,posstr(jx+i,jy))
        i=i-1
    end
    local vert={k}
    i=1
    while jelloes[posstr(jx,jy+i)] and jelloes[posstr(jx,jy+i)].color==j.color do
        ins(vert,posstr(jx,jy+i))
        i=i+1
    end
    i=-1
    while jelloes[posstr(jx,jy+i)] and jelloes[posstr(jx,jy+i)].color==j.color do
        ins(vert,posstr(jx,jy+i))
        i=i-1
    end
    local out={}
    if #horiz>=3 then for i,h in ipairs(horiz) do if not find(out,h) then ins(out,h) end end end
    if #vert>=3 then for i,v in ipairs(vert) do if not find(out,v) then ins(out,v) end end end
    if not test and #horiz>=3 and #vert>=3 then combo() end

    if #out>0 then 
        --if not test then score=score+#out*10 end
        return out 
    end
    return false
end

for x=0,5 do
for y=0,8 do
    jelloes[posstr(x,y)]={tx=x,ty=y,x=leftedge+x*96,y=y*96,color=({'green','yellow','purple','red'})[love.math.random(4)]}
    while match3(posstr(x,y),true) do
        jelloes[posstr(x,y)].color=({'green','yellow','purple','red'})[love.math.random(4)]
    end
end
end

function inprogram(k)
    for i,v in ipairs(program) do
    for j,w in ipairs(v) do
        if w==k then return true end
    end
    end
    return false
end

program={}

function plan(hw_dt)
    if not audio.plan:isPlaying() then audio.plan:play() end
    leftheld=left
    left=love.mouse.isDown(1)
    if not left then leftheld2=nil end
    rightheld=right
    right=love.mouse.isDown(2)
    mox,moy=love.mouse.getPosition()
    if right and not rightheld then
        if action then action=nil; audio.cancel:stop(); audio.cancel:play()
        else
        for i,p in ipairs(program) do
            local sx,sy=strpos(p[1])
            local ex,ey=strpos(p[2])
            if AABB(mox,moy,1,1,leftedge+sx*96,sy*96,96,96) or AABB(mox,moy,1,1,leftedge+ex*96,ey*96,96,96) then rem(program,i); audio.cancel:stop(); audio.cancel:play(); for i2,p2 in ipairs(program) do p2.i=i2 end; break end
        end
        end
    end
    for k,j in pairs(jelloes) do
        local jx,jy=strpos(k)
        if left and not leftheld2 and AABB(mox,moy,1,1,leftedge+jx*96,jy*96,96,96) and ((type(level)=='number' and #program<level+2) or (level=='inf' and #program<7)) then
            if not action then
            if not inprogram(k) then
            if not leftheld then audio.select:stop(); audio.select:play() end
            action={k}
            end
            else
            local kx,ky=strpos(action[1])
            if k==posstr(kx+1,ky) or k==posstr(kx-1,ky) or k==posstr(kx,ky+1) or k==posstr(kx,ky-1) then
            audio.select:stop(); audio.select:play()
            ins(action,k)
            ins(program,action)
            action.i=#program
            action=nil
            end
            end
        end
    end

    if (type(level)=='number' and #program==level+2) or (level=='inf' and #program==7) then
        if love.keyboard.isDown('return') or (left and not leftheld and AABB(mox,moy,1,1,leftedge+6*96+24+12,24*36-128,96,96)) then
        love.update=execute
        old_prog=#program
        audio.plan:stop(); audio.execute:play()
        end
    end

    t = t+1
end

particles={}

function starburst(k,j)
    local kx,ky=strpos(k)
    local sx,sy=leftedge+kx*96,ky*96
    for i=1,12 do
        local new={}
        new.x=sx; new.y=sy
        new.i=({1,2,2,3,3,3})[love.math.random(6)]
        new.img=images[j.color..'star'..tostring(new.i)]
        new.dx=cos(math.rad(love.math.random(0,180)))
        new.dy=love.math.random(-8,-2)/2
        ins(particles,new)
    end
end

function starburst2(kx,ky,color)
    for i=1,12 do
        local new={}
        new.x=kx; new.y=ky
        new.i=({1,2,2,3,3,3})[love.math.random(6)]
        new.img=images[color..'star'..tostring(new.i)]
        new.dx=cos(math.rad(love.math.random(0,180)))
        new.dy=love.math.random(-8,-2)/2
        ins(particles,new)
    end
end

cur_combo=0
longest_combo=0
combo_ind={}
pending_combo=0
function combo()
    cur_combo=cur_combo+1
    if cur_combo>longest_combo then longest_combo=cur_combo end
    if cur_combo>1 then
        pending_combo=pending_combo+40+cur_combo*5
        if combo_ind[#combo_ind] and combo_ind[#combo_ind].t==0 then
        combo_ind[#combo_ind].msg=fmt('%d combo!',cur_combo)
        else
        shout(fmt('%d combo!',cur_combo))
        end
    end
end

function hypotenuse_too_short(c)
    local cx,cy=c.x,c.y
    local dist=0
    while cx>=-8 and cy>=-8 and cx<28*36+8 and cy<24*36+8 do
        cx=cx+cos(c.a-math.pi)*8; cy=cy+sin(c.a-math.pi)*8
        dist=dist+8
    end
    if dist<800 then return true end
    return false
end

function shout(msg)
    local a=love.math.random(0,360)
    ins(combo_ind,{msg=msg,a=math.rad(a),t=0})
    if a<45 or a>=360-45 then combo_ind[#combo_ind].x=28*36; combo_ind[#combo_ind].y=love.math.random(0+6*36,24*36-6*36)  end
    if a>=45+90+90 and a<45+90+90+90 then combo_ind[#combo_ind].x=love.math.random(0+6*36,28*36-6*36); combo_ind[#combo_ind].y=0 end
    if a>=45+90 and a<45+90+90 then combo_ind[#combo_ind].x=0; combo_ind[#combo_ind].y=love.math.random(0+6*36,24*36-6*36) end
    if a>=45 and a<45+90 then combo_ind[#combo_ind].x=love.math.random(0+6*36,28*36-6*36); combo_ind[#combo_ind].y=24*36 end
    if hypotenuse_too_short(combo_ind[#combo_ind]) then rem(combo_ind,#combo_ind); shout(msg) end
end

t2=0
function gameover()
    --for i=1,3 do
    shout('Game over')
    --end
    love.update=function() if t2-t>0 and (t2-t)%90==0 then shout('Game over') end end
end

matched={}

function execute(hw_dt)
    local animating=false

    for k,v in pairs(jelloes) do
        if v.flash then animating=true; v.flash=v.flash-1; if v.flash==0 then animating=false; v.flash=nil end end
    end

    local sus_combo=0
    for k,v in pairs(jelloes) do
        if v.tgtx or v.tgty then 
        animating=true 
        v.x=v.x+(v.tgtx-v.x)*0.2
        v.y=v.y+(v.tgty-v.y)*0.2
        if math.abs(v.tgtx-v.x)<1 and math.abs(v.tgty-v.y)<1 then
            if sus_combo~=2 then sus_combo=1 end
            v.tgtx=nil; v.tgty=nil
            local m= match3(k) 
            if m then sus_combo=2; local same=true; for i,w in ipairs(m) do if not find(matched,w) then same=false; ins(matched,w); jelloes[w].flash=30 end end; if not same then combo() end end
        end
        end
        if v.tgty2 then
        animating=true
        v.acc=v.acc or 0
        v.y=v.y+v.acc
        v.acc=v.acc+0.4
        if v.y>=v.tgty2 then 
            local m= match3(k) 
            if m then local same=true; for i,w in ipairs(m) do if not find(matched,w) then same=false; ins(matched,w); jelloes[w].flash=30 end end; if not same then combo() end end
            v.y=v.tgty2; v.tgty2=nil; v.acc=nil end
        end
    end
    if sus_combo==1 then 
        if cur_combo>1 then shout('Combo end'); audio.cancel:stop(); audio.cancel:play() end
        cur_combo=0 
    end

    removed={}
    if not animating then
    for i,k in ipairs(matched) do
        starburst(k,jelloes[k])
        jelloes[k]=nil
        ins(removed,k)
    end
    matched={}
    end
    local parsed={}
    if not animating then
    table.sort(removed,function(k1,k2) 
        local k1x,k1y=strpos(k1) 
        local k2x,k2y=strpos(k2) 
        return k1y>k2y
    end)
    if #removed>0 then score=score+pending_combo; pending_combo=0 end
    for i,k in ipairs(removed) do
        if i==1 then audio.match:stop(); audio.match:play() end
        score=score+10
        local kx,ky=strpos(k)
        if not find(parsed,kx) then 
        ins(parsed,kx)
        local j=0
        --while (not jelloes[posstr(kx,ky+j)]) and ky+j>0 do j=j-1 end
        --local sep
        --local step1=0
        --local step2=0
        --while jelloes[posstr(kx,ky+step1)]==nil and ky+step1>0 do step1=step1-1 end
        --while jelloes[posstr(kx,ky+step1+step2+1)]==nil and ky+step1+step2+1<8 do step2=step2+1 end
        --sep=(ky+step2)-(ky+step1)-1
        while ky+j>=0 do
            local h=8
            while jelloes[posstr(kx,h)] do h=h-1 end
            for l,w in ipairs(program) do
                if w[1]==posstr(kx,ky+j) then 
                    w[1]=posstr(kx,h) 
                    local wx,wy=strpos(w[2])
                    w[2]=posstr(wx,h+wy-(ky+j))
                    w.tgty2=h*96+48
                end
            end
            if jelloes[posstr(kx,ky+j)] then
            jelloes[posstr(kx,ky+j)].tgty2=h*96--(ky+j+step2)*96
            jelloes[posstr(kx,h)]=jelloes[posstr(kx,ky+j)]--ky+j+step2
            end
            jelloes[posstr(kx,ky+j)]=nil
            j=j-1
        end
        end
    end
    end

    if #program==0 and #matched==0 and not animating and #removed==0 then
        local lowest
        for py=9-1,0,-1 do
        for px=6-1,0,-1 do
        if jelloes[posstr(px,py)]==nil then
            lowest=posstr(px,py)
            goto skip
        end
        end
        end
        ::skip::
        if lowest then
            animating=true
            local kx,ky=strpos(lowest)
            for py=0,9-1 do
            for px=0,6-1 do
                if jelloes[posstr(px,py)]==nil then
                    jelloes[posstr(px,py)]={tx=px,ty=py,x=leftedge+px*96,y=py*96-(ky+1)*96,tgty2=py*96,color=({'green','yellow','purple','red'})[love.math.random(4)]}
                    while match3(posstr(px,py),true) do
                        jelloes[posstr(px,py)].color=({'green','yellow','purple','red'})[love.math.random(4)]
                    end
                end
            end
            end
        end
    end
    
    if #program>0 and not animating and #matched==0 and #removed==0 then
        local sx,sy=strpos(program[1][1])
        local ex,ey=strpos(program[1][2])
        if jelloes[program[1][1]] and jelloes[program[1][2]] then
        local swap=jelloes[program[1][1]]
        jelloes[program[1][1]]=jelloes[program[1][2]]
        jelloes[program[1][1]].tgtx=swap.x
        jelloes[program[1][1]].tgty=swap.y
        jelloes[program[1][2]]=swap
        jelloes[program[1][2]].tgtx=jelloes[program[1][1]].x
        jelloes[program[1][2]].tgty=jelloes[program[1][1]].y
        audio.slime:stop(); audio.slime:play()
        else if cur_combo>1 then shout('Combo end'); audio.cancel:stop(); audio.cancel:play() end
        cur_combo=0 end
        rem(program,1)
    elseif #program==0 and not animating and #matched==0 and #removed==0 then
        start_dialogue(1)
    end
    t=t+1
end

diag_db={
    ['test1']={
        {'Current major jam: Juice Jam! Feel free to talk about any current jam, and post progress updates'},
    },
}
function start_dialogue(id)
    --cur_diag=diag_db[id]
    --cur_diag.i=1
    if id==1 then
    love.update=dialogue
    elseif id==2 then
    love.update=dialogue2
    end
    sc_t=t+1
    diag_box={x=28*36/2,y=12*36,w=1,h=1,tgtx=4*36,tgth=8*36,tgtw=20*36}
end

function end_turn()
    love.update=plan
    if level~='inf' then
    hearts=hearts+longest_combo-(level+2)
    else
    hearts=hearts+longest_combo-7
    end
    if hearts<=0 then gameover() end
    cur_combo=0; longest_combo=0
    old_prog=nil
    if level~='inf' and hearts>0 then level=level+1; if level>5 then level='inf' end end
    leftheld2=true
    audio.execute:stop()
    if hearts>0 then audio.plan:play() end
end

function dialogue()
    leftheld=left
    left=love.mouse.isDown(1)
    if t-sc_t<135+30+30+15+30 and ((left and not leftheld) or tapped('return')) then
        sc_t=sc_t-(135+30+30+15+30)
        diag_box.x=diag_box.tgtx; diag_box.w=diag_box.tgtw; diag_box.h=diag_box.tgth
    elseif t-sc_t>=135+30+30+15+30 and ((left and not leftheld) or tapped('return')) then
        if level==5 and hearts+longest_combo-(level+2)>0 then start_dialogue(2)
        else
            end_turn()
        end
    end
    t=t+1
end

function dialogue2()
    leftheld=left
    left=love.mouse.isDown(1)
    if t-sc_t<60+129 and ((left and not leftheld) or tapped('return')) then
        sc_t=sc_t-(60+129)
        diag_box.x=diag_box.tgtx; diag_box.w=diag_box.tgtw; diag_box.h=diag_box.tgth
    elseif t-sc_t>=60+129 and ((left and not leftheld) or tapped('return')) then
        end_turn()
    end
    t=t+1
end
 
love.update= plan