pico-8 cartridge // http://www.pico-8.com
version 33
__lua__
--week 7 source code
--top secret hush hush

function _init()
	seed = flr(rnd(8000))*4
	baseseed = seed
	songid = 0
	cartdata("ckcw_fnfp8")
	menuitem(1,"back to title",function() dset(60,1) load("fnf-select.p8") end)
	function toggle_downscroll()
		if downscroll == 0 then
			downscroll = 1
			menuitem(2,"downscroll: on",toggle_downscroll)
		else
			downscroll = 0
			menuitem(2,"downscroll: off",toggle_downscroll)
		end
		dset(50,downscroll)
	end
	downscroll = dget(50)
	if downscroll == 0 then
		menuitem(2,"downscroll: off",toggle_downscroll)
	else
		menuitem(2,"downscroll: on",toggle_downscroll)
	end
	difficulty = dget(55)
	local _potseed = dget(54)
	if difficulty == 2 and _potseed ~= 0 then
		seed = _potseed
		baseseed = seed
	end
	fadein = 15
	fadeout = -1
	game_init() --its that easy???
	synctime = 570
end

function _update60()
	if(fadein > 0) fadein-=0.5
	if fadeout > 0 then
		fadeout-=0.5
		if fadeout == 0 then
			if(score > dget(songid) and hp > 0) dset(songid,score)
			dset(60,1)
			load("fnf-select.p8")
		end
	end
	game_update() --yes!!!!
	--if(stat(26) > synctime) synctime = stat(26)
end

function _draw()
	game_draw() --fuck no!!!!
	if(fadein > 0) fadeall(ceil(fadein))
	if(fadeout > -1) fadeall(15-ceil(fadeout))
	--print(synctime,camx,camy,0)
end
-->8
--game controller
function game_init()
	camx = 0
	camy = -10
	camxto = 0
	camyto = 0
	camlerp = 0.0325
	laststep = 0
	step = 0
	score = 0
	hp = 250
	maxhp = 500
	press = {false,false,false,false}
	currentpattern=-1
	
	leftmap = {}
	rightmap = {}
	lastmap = -1
	if difficulty == 0 then
		init_beatmap()
	else
		init_beatmap_hard()
	end
	
	arrows_init()
	parts_init()
	popups_init()
	
	chars_init()
	
	move_cam(0,-2)
end

function game_update()
	laststep = step
	step+=1
	--step = stat(26) + (stat(24)*  350)
	--if(stat(26)+(stat(24)*350) >= 350) step-=1
	if(step < 0) move_cam(0,-4)
	
	if stat(24) ~= currentpattern then
		currentpattern = stat(24)
		step = ((((32*currentpattern)+1)/32)*(synctime/2))
	end
	
	--save seed to clipboard
	if difficulty == 2 and btnp(🅾️,1) then
		printh(baseseed,"@clip")
	end
	
	if abs(step-laststep) < 10 then
		--left side
		if #leftmap > 0 then
			if step >= (((leftmap[1][1]+1)/32)*(synctime/2))-(notetime) then
				if #leftmap[1] > 3 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], leftmap[1][4])
				elseif #leftmap[1] > 2 then
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], leftmap[1][3], false)
				else
					spawn_arrow(leftmap[1][1],0, leftmap[1][2], 0, false)
				end
				deli(leftmap,1)
			end
		end
		
		--right side
		if #rightmap > 0 then
			if step >= (((rightmap[1][1]+1)/32)*(synctime/2))-(notetime) then
				if #rightmap[1] > 2 then
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], rightmap[1][3])
				else
					spawn_arrow(rightmap[1][1],1, rightmap[1][2], 0)
				end
				deli(rightmap,1)
			end
		end
	end
	
	if hp > 0 then
		chars_update()
		arrows_update()
		parts_update()
		popups_update()
	end
	
	--dead
	if hp <= 0 then
		dset(62,chars[2].x-camx)
		dset(63,chars[2].y-camy)
		dset(61,songid)
		load("fnf-gameover.p8")
	end
	
	if stat(24)==-1 and fadeout == -1 then
		fadeout = 15
	end
	
	camx = lerp(camx,camxto,camlerp)
	camy = lerp(camy,camyto,camlerp)
	camera(camx,camy)
	
end

--move camera--
function move_cam(_x,_y,_lerp)
	_lerp = _lerp or camlerp
	camxto = _x
	camyto = _y
	camlerp = _lerp
end

-- get inputs ⬅️⬇️⬆️➡️ --
function get_inputs()
	lastpress = {press[1],press[2],press[3],press[4]}
	press = {false,false,false,false}
	if(btn(⬅️) or btn(⬅️,1)) press[1] = true
	if(btn(⬇️) or btn(⬇️,1)) press[2] = true
	if(btn(⬆️) or btn(⬆️,1) or btn(🅾️)) press[3] = true
	if(btn(➡️) or btn(➡️,1) or btn(❎)) press[4] = true
end

function game_draw()
	cls(1)
	pal()
	local lx = camx/2
	local ly = camy/2
	local llx = flr(camx/2)
	local lly = flr(camy/2)
	
	fillp(0b1000111100101111.1)
	rectfill(-20,-20,148,148,0)
	fillp(█)
	circfill(lx+63,ly+481,400,5)
	fillp(▒)
	circfill(lx+63,ly+481+4,400,4)
	fillp(█)
	circfill(lx+63,ly+485+4,400,4)
	
	color(7)
	--print(step, 0, 0)
	--print(score,0, 8)
	--print(step-laststep,32,0)
	
	
	if hp > 0 then
		chars_draw()
		
		--curtains
		circfill(lx-63,ly-42,118,2)
		circfill(lx+128+63,ly-42,118,2)
		fillp(▒)
		circfill(lx-63-1,ly-42-1,118,8)
		circfill(lx+128+63+1,ly-42-1,118,8)
		fillp(█)
		local _nh = 128-noteheight
		
		--left side
		if downscroll == 0 then
			sspr(56,36,11,12,camx+4+(14*0),camy+_nh,11,12,true)
			sspr(67,36,12,11,camx+4+(14*1),camy+_nh,12,11,false,true)
			sspr(67,36,12,11,camx+4+(14*2),camy+_nh,12,11)
			sspr(56,36,11,12,camx+4+(14*3),camy+_nh,11,12)
		else
			sspr(56,36,11,12,camx+4+(14*0),camy+128-12-_nh,11,12,true)
			sspr(67,36,12,11,camx+4+(14*1),camy+128-12-_nh,12,11,false,true)
			sspr(67,36,12,11,camx+4+(14*2),camy+128-12-_nh,12,11)
			sspr(56,36,11,12,camx+4+(14*3),camy+128-12-_nh,11,12)
		end
		
		--right side
		if downscroll == 0 then
			if(press[1]) arrow_color(0)
			sspr(56,36,11,12,camx+113-14*3,camy+_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(67,36,12,11,camx+113-14*2,camy+_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(67,36,12,11,camx+113-14*1,camy+_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(56,36,11,12,camx+113-14*0,camy+_nh,11,12)
			pal()
		else
			if(press[1]) arrow_color(0)
			sspr(56,36,11,12,camx+113-14*3,camy+128-12-_nh,11,12,true)
			pal()
			if(press[2]) arrow_color(1)
			sspr(67,36,12,11,camx+113-14*2,camy+128-12-_nh,12,11,false,true)
			pal()
			if(press[3]) arrow_color(2)
			sspr(67,36,12,11,camx+113-14*1,camy+128-12-_nh,12,11)
			pal()
			if(press[4]) arrow_color(3)
			sspr(56,36,11,12,camx+113-14*0,camy+128-12-_nh,11,12)
			pal()
		end
		
		--particles
		parts_draw()
		
		--popups
		popups_draw()
		
		--arrows
		if downscroll == 0 then
			arrows_draw()
		else
			arrows_draw_downscroll()
		end
		
		--health bar
		if downscroll == 0 then
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+127-8,camx+63-42+84,camy+127-2,3)
			rectfill(camx+63-42+1,camy+127-7,camx+63-42+84-1,camy+127-3,11)
			rectfill(camx+63-42,camy+127-8,_xx,camy+127-2,2)
			rectfill(camx+63-42+1,camy+127-7,_xx,camy+127-3,8)
			palt(11,true)
			palt(0,false)
			sspr(115,30,13,9,_xx+3,camy+127-9)
			sspr(56,74,15,14,_xx-5-11,camy+127-13)
		else
			local _xx = camx+63-42+flr(84*((maxhp-hp)/maxhp))
			rectfill(camx+63-42,camy+128-(127-8),camx+63-42+84,camy+128-(127-2),3)
			rectfill(camx+63-42+1,camy+128-(127-7),camx+63-42+84-1,camy+128-(127-3),11)
			rectfill(camx+63-42,camy+128-(127-8),_xx,camy+128-(127-2),2)
			rectfill(camx+63-42+1,camy+128-(127-7),_xx,camy+128-(127-3),8)
			palt(11,true)
			palt(0,false)
			sspr(115,30,13,9,_xx+3,camy+128-9-(127-9))
			sspr(56,74,15,14,_xx-5-11,camy+128-16-(127-13))
		end
		
		--score
		if downscroll == 0 then
			print(tostr(score),camx+64-#tostr(score)*2,camy+4,7)
		else
			print(tostr(score),camx+64-#tostr(score)*2,camy+128-8,7)
		end
		
	else
		--dead
		rectfill(camx,camy,camx+128,camy+128,0)
		palt(0,false)
		palt(3,true)
		fade(7)
		sspr(28,30,27,27,chars[2].x-flr(27/2),chars[2].y-27)
		pal()
	end
	pal()
end

function dir_to_ang(_dir)
	if(_dir == 0) return 180
	if(_dir == 1) return 90
	if(_dir == 2) return 270
	return 0
end

--linear interpolation
function lerp(pos,tar,perc)
 return pos+((tar-pos)*perc)
end

-- fade to black
local fadetable0={
{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
{1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
{2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
{3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
{4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
{5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
{6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
{7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
{8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
{9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
{10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
{11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
{12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
{13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
{14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
{15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

function fade(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0)
		else
			pal(c,fadetable0[c+1][flr(i+1)])
		end
	end
end

function fadeall(i)
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0,1)
		else
			pal(c,fadetable0[c+1][flr(i+1)],1)
		end
	end
end

function spr_r(sx,sy,x,y,a,w,h)
 sw=(w or 8)
 sh=(h or 8)
 x0=flr(0.5*sw)
 y0=flr(0.5*sh)
 a=a/360
 sa=sin(a)
 ca=cos(a)
 for ix=0,sw-1 do
  for iy=0,sh-1 do
   dx=ix-x0
   dy=iy-y0
   xx=flr(dx*ca-dy*sa+x0)
   yy=flr(dx*sa+dy*ca+y0)
   if (xx>=0 and xx<sw and yy>=0 and yy<=sh) then
    pset(x+ix,y+iy,sget(sx+xx,sy+yy))
   end
  end
 end
end

--choose random array
function choose(t)
	return t[flr(rnd(#t))+1]
end
-->8
--beatmap

--normal difficulty
function init_beatmap()
	
	--girlfriend
	map_add(leftmap,64,"0,0:8,3:16,0:24,3")
	--boyfriend
	map_add(rightmap,64+32,"0,0:8,3:16,0:24,3")
	--pose
	map_add(leftmap,64+32,"28,4")
	
	--girlfriend
	map_add(leftmap,128,"0,2:8,1:16,2:24,1")
	--boyfriend
	map_add(rightmap,128+32,"0,2:8,1:16,2:24,1")
	--pose
	map_add(leftmap,128+32,"28,4")
	
	--girlfriend
	map_add(leftmap,192,"0,0:8,2:16,1:24,3")
	--boyfriend
	map_add(rightmap,192+32,"0,0:8,2:16,1:24,3")
	
	--girlfriend
	map_add(leftmap,256,"0,1:4,1:8,2:16,1:20,1:24,3")
	--boyfriend
	map_add(rightmap,256+32,"0,1:4,1:8,2:16,1:20,1:24,3")
	
	--girlfriend
	map_add(leftmap,320,"0,1:2,2:4,3:6,2:12,3")
	--boyfriend
	map_add(rightmap,320+16,"0,1:2,2:4,3:6,2:12,3:16,3:20,1:24,0:28,1:32,2:36,3:40,0:44,2:48,1,24")
	
	music(0)
end

--hard difficulty
function init_beatmap_hard()
	
	--girlfriend
	map_add(leftmap,64,"0,0:8,3:16,0:24,3")
	--boyfriend
	map_add(rightmap,64+32,"0,0:8,3:16,0:24,3")
	--pose
	map_add(leftmap,64+32,"28,4")
	
	--girlfriend
	map_add(leftmap,128,"0,2:8,1:16,2:24,1")
	--boyfriend
	map_add(rightmap,128+32,"0,2:8,1:16,2:24,1")
	--pose
	map_add(leftmap,128+32,"28,4")
	
	--girlfriend
	map_add(leftmap,192,"0,0:8,2:16,1:24,3")
	--boyfriend
	map_add(rightmap,192+32,"0,0:8,2:16,1:24,3")
	
	--girlfriend
	map_add(leftmap,256,"0,1:4,1:8,2:16,1:20,1:24,3")
	--boyfriend
	map_add(rightmap,256+32,"0,1:4,1:8,2:16,1:20,1:24,3")
	
	--girlfriend
	map_add(leftmap,320,"0,1:2,2:4,3:6,2:12,3")
	--boyfriend
	map_add(rightmap,320+16,"0,1:2,2:4,3:6,2:12,3:16,3:20,1:24,0:28,1:32,2:36,3:40,0:44,2:48,1,24")
	
	map_add(rightmap,384+16,"0,0:1,1:2,2:3,3:4,2:5,1:6,0:7,1:8,2:9,3:10,2:11,3:12,2:13,3:14,1:15,0")
	
	music(0)
end

function map_add(_map, _off, _s)
	local _m = lastmap
	if(_map == leftmap) _m = 0
	if(_map == rightmap) _m = 1
	if difficulty == 2 and _m ~= lastmap then
		if _m == 1 then
			srand(seed)
		else
			seed += 1
			srand(seed)
		end
		lastmap = _m
	end
	
	lastrandom = -1
	local _ar = split(_s,":")
	for _a in all(_ar) do
		local _beat = split(_a)
		if difficulty == 2 and _beat[2] ~= 4 then
			repeat
				_beat[2] = flr(rnd(4))
			until _beat[2] ~= lastrandom or flr(rnd(8)) == 0
			lastrandom = _beat[2]
		end
		_beat[1] += _off
		add(_map,_beat)
	end
end
-->8
--arrows
function arrows_init()
	leftarrows = {}
	rightarrows = {}
	lefttrails = {}
	righttrails = {}
	combo = 0
	noteheight = 116
	notetime = 1*90
	arrowcols = {2,1,3,4}
	lastrandom = -1
end

function arrow_color(_dir)
	if _dir == 0 then
		pal(5,2)
		pal(6,14)
	elseif _dir == 1 then
		pal(5,1)
		pal(6,12)
	elseif _dir == 2 then
		pal(5,3)
		pal(6,11)
	elseif _dir == 3 then
		pal(5,4)
		pal(6,9)
	end
end

function spawn_arrow(_off,_side,_dir,_len,_ugh)
	local _arrow = {x=_dir*14,y=128-(noteheight/notetime),dir=_dir,len=_len,ugh=_ugh}
	
	--local _offset = flr((step - (((_off+1)/32)*(synctime/2))-(notetime)))
	--for i=1,_offset do
	--	_arrow.y -= noteheight/notetime
	--end
	
	if _side == 0 then
		_arrow.x += 4
		add(leftarrows,_arrow)
		if _len > 0 then
			add(lefttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	else
		_arrow.x += 71
		add(rightarrows,_arrow)
		if _len > 0 then
			add(righttrails,{x=_arrow.x,y=128-(noteheight/notetime),dir=_dir,len=_len})
		end
	end
end

function arrows_update()
	
	get_inputs()
	_pressed = {false,false,false,false}
	hashit = false
	
	for _a in all(leftarrows) do
		_a.y -= noteheight/notetime
		if _a.y <= 128-noteheight then
			if _a.dir == 4 then
				char_animate(1,4,true)
				char_animate(2,4,true)
			else
				char_animate(1,_a.dir,true)
				move_cam(0,-4)
				poke(0x5f43)
			end
			del(leftarrows,_a)
		end
	end
	
	for _a in all(rightarrows) do
		_a.y -= noteheight/notetime
		--note goes off screen
		if _a.y <= -10 then
			poke(0x5f43,15)
			hp -= 10
			combo = 0
			del(rightarrows,_a)
		end
		--note collision
		if _a.y <= 128-noteheight+15+4 and _a.y >= 128-noteheight-10-8 then
			move_cam(20,4)
			--note hit
			if press[_a.dir+1] and not hashit and not lastpress[_a.dir+1] then
			--if _a.y <= 128-noteheight+2 then
				hashit = true
				poke(0x5f43)
				
				if(difficulty==3) corrupt()
				
				--animate char
				char_animate(2,_a.dir,true)
				
				create_popup(65,42,choose(split"gOOD!,sICK!!"))
				combo += 1
				if(combo >= 10) create_popup(65,50,"combo " .. tostr(combo))
				
				_pressed[_a.dir+1] = true
				--score += ceil(200*(1-abs(_a.y-(128-noteheight))/7))
				score += 20
				hp += 10
				hp = min(maxhp,hp)
				fx_hit(_a.x+3,_a.y+3,arrowcols[_a.dir+1])
				del(rightarrows,_a)
			end
		end
	end
	
	for _t in all(lefttrails) do
		_t.y -= noteheight/notetime
		
		if(_t.y <= 128-noteheight-(_t.len*12)) del(lefttrails,_t)
	end
	
	for _t in all(righttrails) do
		_t.y -= noteheight/notetime
		
		if(_t.y <= 128-noteheight-(_t.len*8)) del(righttrails,_t)
		
		--trail collision
		if _t.y <= 128-noteheight and _t.y >= 128-noteheight-(_t.len*8) then
			--hold button
			if press[_t.dir+1] then
			--if true then
				--score += 2
				if(step%6 == 0) char_animate(2,_t.dir,true)
				hp += 1
				hp = min(maxhp,hp)
				spawn_part(_t.x+3,128-noteheight+7,rnd(),1,0.25,0.25,0.1,0.25,arrowcols[_t.dir+1])
			end
		end
		
	end
	
	--pressing when no note is there
	for i=1,4 do
		if press[i] and not lastpress[i] and not _pressed[i] then
			score -= 1
			--animate char
			char_animate(2,i-1,false)
			
			create_popup(65,42,choose(split"bAD,sHIT"))
			hp -= 10
			combo = 0
			
			sfx(1,3)
			poke(0x5f43)
		end
	end
	
end

function arrows_draw()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*12),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+_t.y+(_t.len*8),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		if _a.dir < 4 then
			arrow_color(_a.dir)
			if _a.dir == 0 or _a.dir == 3 then
				sspr(56,36,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
			else
				sspr(67,36,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
			end
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,36,11,12,camx+_a.x,camy+_a.y,11,12,_a.dir == 0)
		else
			sspr(67,36,12,11,camx+_a.x,camy+_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end

function arrows_draw_downscroll()
	for _t in all(lefttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*8)),arrowcols[_t.dir+1])
	end
	for _t in all(righttrails) do
		rectfill(camx+_t.x+5,camy+128-max(128-noteheight+7,_t.y+1),camx+_t.x+6,camy+128-(_t.y+(_t.len*8)),arrowcols[_t.dir+1])
	end
	for _a in all(leftarrows) do
		if _a.dir < 4 then
			arrow_color(_a.dir)
			if _a.dir == 0 or _a.dir == 3 then
				sspr(56,36,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
			else
				sspr(67,36,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
			end
		end
		pal()
	end
	for _a in all(rightarrows) do
		arrow_color(_a.dir)
		if _a.dir == 0 or _a.dir == 3 then
			sspr(56,36,11,12,camx+_a.x,camy+128-12-_a.y,11,12,_a.dir == 0)
		else
			sspr(67,36,12,11,camx+_a.x,camy+128-12-_a.y,12,11,false,_a.dir == 1)
		end
		pal()
	end
end
-->8
--particles
function parts_init()
	parts = {}
end

function fx_hit(_x,_y,_col)
	for i=0,3 do
		spawn_part(_x,_y,(i/4)+0.125,2,0.15,0.125,0.015,0.0675,_col)
	end
end

function spawn_part(_x,_y,_dir,_spd,_fric,_size,_growth,_fade,_col)
	if downscroll > 0 then
		_y = 128 - _y
	end
	add(parts,{
	x=camx+_x,
	y=camy+_y,
	dir=_dir,
	spd=_spd,
	fric=_fric,
	r=_size,
	growth=_growth,
	growthspd=_growth,
	fadeam=_fade,
	fade=0,
	col=_col,
	hs=sin(_dir)*_spd,
	vs=cos(_dir)*_spd,
	lx=_x,
	ly=_y
	})
end

function parts_update()
	for _p in all(parts) do
		if(abs(_p.hs) > 0) _p.hs -= _p.fric*sgn(_p.hs)
		if(abs(_p.vs) > 0) _p.vs -= _p.fric*sgn(_p.vs)
		_p.lx = _p.x
		_p.ly = _p.y
		_p.x += _p.hs
		_p.y += _p.vs
		_p.growthspd += _p.growth
		_p.r += _p.growthspd
		_p.fade += _p.fadeam
		if(_p.fade >= 1 or _p.r <= 0) del(parts,_p)
	end
end

function parts_draw()
	for _p in all(parts) do
		if(_p.fade >= 0.6) fillp(▒)
		if(_p.fade >= 0.85) fillp(░)
		circfill(_p.lx,_p.ly,_p.r,_p.col)
		circfill(_p.x,_p.y,_p.r,_p.col)
		fillp(█)
	end
end
-->8
--characters
function chars_init()
	chars={
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=64,y=64,sx=64,sy=64,hurt=false,rest=0},
		{sp=0,spx=0,spy=0,spw=27,sph=27,x=100,y=102,sx=100,sy=102,hurt=false,rest=0},
		{spx=55,spy=0,spw=29,sph=45,x=64,y=64}
	}
end

function char_animate(_chr,_dir,_good)
	if _chr == 1 then
		if _dir == 0 then
			chars[_chr].spx = 60
			chars[_chr].spy = 90
			chars[_chr].spw = 30
			chars[_chr].sph = 38
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 0
			chars[_chr].spy = 91
			chars[_chr].spw = 30
			chars[_chr].sph = 37
			chars[_chr].y = chars[_chr].sy + 2
		elseif _dir == 2 then
			chars[_chr].spx = 30
			chars[_chr].spy = 88
			chars[_chr].spw = 30
			chars[_chr].sph = 40
			chars[_chr].y = chars[_chr].sy - 3
		elseif _dir == 3 then
			chars[_chr].spx = 90
			chars[_chr].spy = 90
			chars[_chr].spw = 31
			chars[_chr].sph = 38
			chars[_chr].x = chars[_chr].sx + 4
		elseif _dir == 4 then
			chars[_chr].spx = 96
			chars[_chr].spy = 44
			chars[_chr].spw = 31
			chars[_chr].sph = 43
			chars[_chr].y = chars[_chr].sy
			chars[_chr].x = chars[_chr].sx+2
		end
	else
		if _dir == 0 then
			chars[_chr].spx = 0
			chars[_chr].spy = 60
			chars[_chr].spw = 28
			chars[_chr].sph = 29
			chars[_chr].x = chars[_chr].sx - 4
		elseif _dir == 1 then
			chars[_chr].spx = 28
			chars[_chr].spy = 30
			chars[_chr].spw = 27
			chars[_chr].sph = 27
			chars[_chr].y = chars[_chr].sy + 4
		elseif _dir == 2 then
			chars[_chr].spx = 0
			chars[_chr].spy = 28
			chars[_chr].spw = 27
			chars[_chr].sph = 32
			chars[_chr].y = chars[_chr].sy - 4
		elseif _dir == 3 then
			chars[_chr].spx = 28
			chars[_chr].spy = 57
			chars[_chr].spw = 27
			chars[_chr].sph = 29
			chars[_chr].x = chars[_chr].sx + 4
		elseif _dir == 4 then
			chars[_chr].spx = 0
			chars[_chr].spy = 0
			chars[_chr].spw = 28
			chars[_chr].sph = 28
		end
	end
	
	chars[_chr].sp = _dir
	chars[_chr].hurt = not _good
	chars[_chr].rest = 30
end

function chars_update()
	for i=1,2 do
		chars[i].x = lerp(chars[i].x,chars[i].sx,0.125)
		chars[i].y = lerp(chars[i].y,chars[i].sy,0.125)
		if chars[i].rest > 0 then
			chars[i].rest -= 1
			if chars[i].rest == 0 then
				chars[i].sp = 0
				chars[i].hurt = false
			end
		end
		if chars[i].rest == 0 then
			if i == 1 then
				if flr(step/(synctime/8)) % 2 == 1 then
					chars[i].sp = -1
					chars[i].spx=55
					chars[i].spy=0
					chars[i].spw=30
					chars[i].sph=36
				else
					chars[i].sp = -2
					chars[i].spx=85
					chars[i].spy=0
					chars[i].spw=30
					chars[i].sph=36
				end
			else
				if flr(step/(synctime/8)) % 2 == 1 then
					chars[i].spx=0
					chars[i].spy=0
					chars[i].spw=27
					chars[i].sph=27
				else
					chars[i].spx=28
					chars[i].spy=0
					chars[i].spw=26
					chars[i].sph=29
				end
			end
		end
	end
end

function chars_draw()
	--girlfriend
	--[[
	palt(0,false)
	palt(10,true)
	local lx = camx/4
	local ly = 0
	if flr(step/(350/8)) % 2 == 1 then
		sspr(115,0,13,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 14, true)
		sspr(115,0,13,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(85,0,29,47,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(47/2))
	else
		sspr(115,15,12,15,lx-1+chars[3].x+16,ly+chars[3].y+12)
		sspr(115,15,12,15,lx+2+chars[3].x-16-12,ly+chars[3].y+12, 12, 14, true)
		sspr(55,0,29,46,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
	end
	]]
	pal()
	
	for i=1,2 do
		palt(0,false)
		palt(3,true)
		local _c = chars[i]
		if(_c.hurt) fade(7)
		--if i == 1 then sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph,true)
		if i == 1 then
			palt(3,false)
			palt(10,true)
			local lx = camx/4
			local ly = 0
			
			if flr(step/(synctime/32)) % 2 == 0 then
				sspr(56,62,30,12,lx+_c.x-flr(29/2),ly+_c.y+4-flr(47/2)+22+13)
				sspr(115,0,13,15,lx+2+_c.x-16-12-1,ly+_c.y+12, 13, 15, true)
				sspr(115,0,13,15,lx-1+_c.x+16,ly+_c.y+12)
				--sspr(104,57,24,23,lx+chars[3].x-flr(29/2)+4,ly+chars[3].y+4-flr(47/2)-1)
			else
				sspr(56,49,30,12,lx+_c.x-flr(29/2),ly+_c.y+4-flr(47/2)+22+13)
				sspr(115,15,12,15,lx-1+_c.x+16,ly+_c.y+12)
				sspr(115,15,12,15,lx+2+_c.x-16-12,ly+_c.y+12, 12, 15, true)
				--sspr(98,80,30,22,lx+chars[3].x-flr(29/2),ly+chars[3].y+4-flr(46/2))
			end
			
			if _c.sp >= 0 then
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,lx+_c.x-flr(_c.spw/2),ly+_c.y+28-_c.sph-12,_c.spw,_c.sph)
			else
				if flr(step/(synctime/32)) % 4 == 0 then
					sspr(55,23,30,13,lx+_c.x-flr(29/2)-1,ly+_c.y+4-flr(47/2)+22,32,14)
					sspr(90,0,24,23,lx+_c.x-flr(29/2)+4,ly+_c.y+4-flr(47/2),26,22)
				elseif flr(step/(synctime/32)) % 4 == 1 then
					sspr(55,23,30,13,lx+_c.x-flr(29/2),ly+_c.y+4-flr(47/2)+22)
					sspr(90,0,24,23,lx+_c.x-flr(29/2)+4,ly+_c.y+4-flr(47/2)-1)
				elseif flr(step/(synctime/32)) % 4 == 2 then
					sspr(55,23,30,13,lx+_c.x-flr(29/2)-1,ly+_c.y+4-flr(47/2)+22,32,14)
					sspr(55,1,30,22,lx+_c.x-flr(29/2)-2,ly+_c.y+4-flr(46/2)+1,32,21)
				elseif flr(step/(synctime/32)) % 4 == 3 then
					sspr(55,23,30,13,lx+_c.x-flr(29/2),ly+_c.y+4-flr(47/2)+22,30,13)
					sspr(55,1,30,22,lx+_c.x-flr(29/2),ly+_c.y+4-flr(46/2))
				end
			end
		else
			if _c.sp == 4 then
				local _xx = _c.x-flr(_c.spw/2)
				local _yy = _c.y-_c.sph
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_xx,_yy,_c.spw,_c.sph)
				sspr(71,74,5,4,_xx+13,_yy+11)
				sspr(79,36,10,13,_xx+17,_yy+9)
			else
				sspr(_c.spx,_c.spy,_c.spw,_c.sph,_c.x-flr(_c.spw/2),_c.y-_c.sph,_c.spw,_c.sph)
			end
		end
		pal()
	end

end
-->8
--popups system
function popups_init()
	popups={}
end

function create_popup(_x,_y,_txt)
	add(popups,{
	x=_x,y=_y,sy=_y,txt=_txt,fade=0
	})
end

function popups_update()
	for _p in all(popups) do
		if _p.fade < 1 then
			_p.y = lerp(_p.y,_p.sy-8,0.125)
			_p.fade += 1/15
			if _p.fade >= 1 then
				del(popups,_p)
			end
		end
	end
end

function popups_draw()
	local lx = camx/2
	local ly = camy/2
	for _p in all(popups) do
		if(_p.fade >= 0.5) fillp(▒)
		if(_p.fade >= 0.75) fillp(░)
		for i=-1,1 do
			for j=-1,1 do
				print(_p.txt,lx+_p.x+i-#(_p.txt)*2,ly+_p.y+j,0)
			end
		end
		print(_p.txt,lx+_p.x-#(_p.txt)*2,ly+_p.y,7)
		fillp(█)
	end
end
-->8
function corrupt()
	--sprite corruption
	for i=1,10 do
		poke(rnd(0x1fff),rnd(255))
	end
	
	--music/sound corruption
	if(flr(rnd(25))==1) poke(0x5f40+rnd(3),rnd(255))
	for i=1,5 do
		poke(rnd(0x42ff-0x3200)+0x3200,rnd(255))
	end
	
	--chance to flip/turn screen
	if(flr(rnd(1000))==0) poke(0x5f2c,rnd({0,129,130,131,133,134,135}))
	
end
__gfx__
3333333333333322222223333333333333333332222222223333333aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa22aaaaaaaaaaa0001111aaaaaa
33333333332222eeeee28033333333333333322eeeeeee280333333aaaaaaaaaaaa2222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa222aaaaaaaaa00655551111aa
3333333332eeeeeeee28880333333333333332eeeeeee2888033333aaaaaaaaaaaaa242222aaaaaaaaaaaaaaaaaaaaaaaa222222442aaaaaaaa116550000551a
333333332eeeee1eee2888033333333333332eeee6eee2888033333aaaaaaaaa222222444442aaaaaaaaaaaaaaaaaaaa244444222222aaaaaaa1165051110651
333333330000e16ee28888803333333333330cee16ee28888803333aaaaaaa24444444444f442aaaaaaaaaaaaaaaa2aa44444444444442aaaaa1165055111051
33333331066606cee288888033333333333066606cee28888803333aaaaaa244444444f44f444aaaaaaaaaaaaaaa2aa24f444444444f442aaaa1165016611051
3333333166c666cce20888803333333333166c666c0e20888803333aaaaaa4ff44ff44fff44442aaaaaaaaaaaaaa2a22fffffff4f4fff44aaaa1165500111651
33333316ccccc6cc1088880720003333316cc0cc6cce08888822000aaa2aa4444f4f4f44444442aaaaaaaaaaaaa24244444f4f4ff4444442aaa1165550006551
33333316cc0cccc61000007721cc3333316cc0ccccc6000080771ccaaa2a224444444444444442aaaaaaaaaaaaa244424444444444444444aaa1165000055551
333333111cc0ff6f0f6cc12f2310330003116c01fff0f6cc1f2f010aaa44244444444444444422aaaaaaaaaaaaaa22244444244444444444aaa1150111106551
333333336c1f0ff20ff1f14423333016d036c1f0ff20ff11cf22333aaa24242224442ee244ee42aaaaaaaaaaaaaaa2422e2224e244444424aaa1150511110551
33000331c12ff02f47fff00333330dd16d0c12ff02f47fff2223333aaaa22222e24e220e22fe2422aaaaaaaaaaaaa2222002ee20224ee442aaa005056611051a
306dd03112f774777f772723333300dd00012f774777f7722333333aaaaa2222e00ee402e2f2222aaaaaaaaaaaaa22242e00eee02e22e222aaa005000111051a
01d16d2332777f77f772772333330d0d16022777f77f77276233333aaaaa2242ee0eff4f422224aaaaaaaaaaaaaa2242ff44eff4f4422222aaa001101111651a
01d0dd7232f777ff722267623333301610722f777ff722677233333aaaaa2442ef4fffff4424442a2aaaaaaaaaaa2442fffffffff222242aaaa00011000011aa
010d602722222228866627723333330007273222228866667723333aaaaaa42efff2082f224444442aaaaaaaaa2aa240fff2082ff24244aa22a000111aaaaaaa
30160072222266e77e670ff23333332f772f26666e66e7202223333aaaaaa40effff88ff42444442aaaaaaaaaa22244400ff88ff2242442242a006555111aaaa
330007771cc777e7ee70f7f233333327777726077e7ee72ff433333aaa2a444002222222ef244442aaaaaaaaaaa24444e2880042e42444442aa11655000511aa
333277f71ccc10000011777f1333332ff7740cc077ee702fff33333aaa22444442888884ffe444442aaaaaaaaaa224444288224ef2444442aaa116505110651a
3332f7ff2fff21001ccc1f7f12333332fff771110111cc177fc3333aaa244444e02222224ff444442aaaaaaaaaa224440222224ff24444442aa116505511051a
333322228eeee0f8112fcccc8233333224fffff2111cccc11113333aaaa24444e00000222ff444422aaaaaaaaaaa244200000244f24444442aa116501611051a
33333326767e2e88128ee112823333333222eeef00102f1cc123333aaaaa444e2efff4400ef2442aaaaaaaaaaaaaa422effff000fe244442aaa115500011651a
333332ed7d8288828286666d23333333333267ee2f212feeee23333aaaaa24ff2fffffffe0ffe22aaaaaaaaaaaaa2ef2fffffffe2fffe22aaaa115555006551a
33332eee2228222228877d2d7e2333333277767288ee8e777233333aaa111ef42ef222eff0ef22f211aaaaaa1112ff2eff22efff2f22fe11aaa115500055551a
3333288e8882d6d62287e888e87233332ee27728882ee7777722333a11555552ef2fff2ee46666555511aa11555555eff2ff4ef46666655511a115011106551a
33333277676dd00222ee8888276233332ee82882e62287eeeee8233a1055622fff2fee22111110665051aa10555624ff2feef2411110066051a115051110551a
333333222220033330677777662333327882222e0008ee888882233150122ffff22ffe2111116660601511501522eff41ffef1111166610615111505611051aa
33333333333333333302222222333332776776233302ee888826233156288822222eff000166611106551155628822221eff21111661111065111500011051aa
33333333333332222333333333333333222222333306677777623330560228820202ef2556111111065500556022220210ef42016111111065000100110651aa
3333333333332eeee2233333333333333333333333302222222333305611122111022fe2201111111615005161111111052ff226111111106500001000111aaa
3333333333000eeeeee22333333333333333333322222223333333355611111111022ff8201111111615555161111111052ff82211111110655bbb1111bbbbbb
33333333316660eee1eee2233333333333333222eeeee2803333333556011111111028f82111111106155551611111111028f88211111110655bb11ccc111bbb
333333331660c60061eeeee23333333333332eeeeeee28880333333556011111100002882001111106155555161110000002888200011106155b1c1cccc1c1bb
333333316cc0cc60c0eee228033333333332eeee1eee288803333335556011100000002220000110615555555160000000002220000000615551ccc1ccc1c1bb
333333311c6c0cc6c0e2288803333333333100e16ee28888803333355556660000000000000000661555555555166000000000000006661555511cc11111c1bb
3333333316cc0cc6cc28888880333333330c6606cee288008033333555551166666666666666661555555555555551111111111111115555555b1c11c1c11111
33333331111101cccc88008880333333331c6666cce2800880223330000055000000000555500003322233333aaaaaaaaaaaaaaaaaaaaaaaaaab11c1c11cc1c1
33333331322ff0161600088880333333316c06c6cce2808802f20c00000566550000005666650003327723223aaaaaaaaaaaaaaaaaaaaaaaaaab1b1cccc1c11b
333333332ffff06f0008888880333333316cc0cccc66000007721c10000566665000056666665003327722772aaaaaaaaaaaaaaaaaaaaaaaaaabbbb1111111bb
333333332777f4200f161180023333331611cc00c6601f6c61f20330555556666500566666666503327722772aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
33333330007777f4f416cc17f23333331131cc100112f4f61c133330566666666650566666666503327727772aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
3333330d0d07f777227f1c77711333333316c0fff2f0727ff2333330566666666655666666666653327727723aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
33333010dd107ff22874242f21cc3333331612727070277f223333305666666666556656666566532777f7233aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
3333306d0160227728f23222301c333332212f77007777726623333056666666665055566665550327fff7223aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
32220011d6d0662222233333330033224ff220007722772666233330555556666500005666650002ff22ff772aaaaaaaaaaaaaaaaaaaaaaa22aaaaaaaaaaaaaa
32ff7006dd06886666623333333332f777710d6107f8826222333330000566665000005666650002727722ff2aaaaaaaaaaaaaaaaaaaaaaaa442aaaaaaaaaaaa
32f77f00002e76862666233333332777f770661d60222684ff433330000566550000005555550002ff7f22223aaaaaaaaaaaaaaaaaaa2222a24224422aaaaaaa
2f77472f266eee7622262333333327474720dd06007e77e07773333000005500000aaaaaaaaaaaa322ff2ff23aaaaaaaaaaaaaaaaa2444442224444442aaaaaa
2ff772ff276777772ff2233333332f4f222011d0d0000011c7113333aaaaaaaaaaaaaaaaaaaaaaa3332222233aaaaaaaaaaaaaaaa244444444444444444aaaaa
2f747f22e20007772ff2333333333222ff21011110111c2cccc13333555551166666666666666661555555aaaaaaaaaaaaaaaaaaaf4444444444444444f2aaaa
2f7722eeee2000cc177f133333333333226770000e8222eeccce2333555555660000000110000066555555aaaaaaaaaaaaaaaaaa2ff444fff4f4f44fffff2aaa
3222328eeee0e111cf777133333333332e77e7828882ee8676e22233555566011111111111111660665555aaaaaaaaaaaaaaaaa2fffffffffffffff222ff2aaa
333326767e2e80811177f11333333332eee22228222e28767227ee23555600111111111111116611006555aaaaaaaaaaaaaa2aa2f444ff44f4ff4f2ff2224aaa
3332ed7d82888de861111113333333328ee88882e000087e8888e823555601111111000000161111106555aaaaaaaaaaaaaa22a44444444444f4222ff2ff22aa
332eee22282222e877227e823333333327767720333302ee88882723055611111110555555011111116550aaaaaaaaaaaaaa2444444444444442ff2f2ff222aa
3278ee8882d6d228e888827233333333322222333333306676776233011611111110555555011111116110aaaaaaaaaaaaaa2442444424424442ffffff2242aa
327782222d00308ee888826233333333333333333333332222222333011601111110555555011111106110aaaaaaaaaaaaaa24244442442422422ef00ff242aa
33277777220330622888766233333333333333333332222233333333011601111111000000111111106110aaaaaaaaaaaaaaa42444ee2e24ee2442e0e22242aa
3332222222333306667762223333333333333333222eeee203333333011560110000000000000011065110aaaaaaaaaaaaaaa224420000e2000222ee224422aa
3333333333333332222223333333333333333222eeeee82880333333a0115660000000000000000665110aaaaaaaaaaaaaaaa2242ef0ff0f0ff02ff22444422a
3333333333322222333333333333333333332eeeeeeee28888033333a0111556660000000000666551110aaaaaaaaaaaaaaaa2422e00ffffffff2ff42e4442aa
33333333322eeeee222233333333333333332eeee6ee828088033333aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa442effffff222f2ff22e2442aaa
3333333322eeeeeeee282333333333333333000e16ee280888803333555555555555555555555555555555aaaaaaaaaaaaaaaa42e222ef2288e2ff222442a2aa
33333333000ee1eee288803333333333333066600c1e200888823333555555666666666666666666555555aaaaaaaaaaaaaaaa442f2f2eee882ff242444224aa
333333316660066e2888803333333333333160c60cc18088882f0011555566000000000000000000665555aaaaaaaaaaaaaaaa442fff2222222ff224444444aa
3333331066660c1e28888803333333333316c0ccc6c10200007721c1555601111111111111116661106555aaaaaaaaaaaaaaa24442eee288882ff244444442aa
33333160cccc6c0288808803333333333316cc0c11c6006c110f2333556011111111111111166111110655aaaaaaaaaaaaaaa2444422e2888822244444442aaa
3333311c0ccccc02800888033333333333111c100f6200f6f1142333050111111111100006611111111050aaaaaaaaaaaaaaa444442fe222282224444442aaaa
333333160011c668088888223333333333336c1200ff0f4ff2223333010111111111055550111111111010aaaaaaaaaaaaaa244442fff2022222444444422aaa
3333316c100f61f0000882f23333333333316132f0274727f2333333010111111111055550111111111010aaaaaaaaaaaaa2244442ff22000222444444442aaa
333331112f0f1f0016c00771c13333333331132f7477f88723333333016011111100000000001111110610aaaaaaaaaaaa2444444222fffff002244442242aaa
333331332747f20ff11cf2f01c0333333223330007f2887262333333015601100000000000000001106510aaaaaaaaaaaaa2242442ff222ffff2244442a42aaa
33333332f777774777f04223300333322ff210d11022222672333333a0155660000000000000000066510aaaaaaaaaaaaaaaaaa242e2fff2ffff244442a2aaaa
3333333277f7777277f2223333333327777d0d61600e762222333333a0111556666000000006666655110aaaaaaaaaaaaaaaaa2442e2ffef2fff244442aaaaaa
33333333277fff882f27233333333277f47100060d0770ff03333333bbbb000bbbbbbbb33333aaaaaaaaaaaaaaaaaaaaaaa1111112f2feef2fff2111111aaaaa
3333223302000228226672333333324ff4f601ddd10cc17721333333bbbb0880bbbbbbb33332aaaaaaaaaaaaaaaaaaaaa115556222f2ffff2fff266555511aaa
3222ff210016086226222233333332f4f2ff201110cc1c1772133333bbbb0880bbbbbbb33328aaaaaaaaaaaaaaaaaaaaa105222ffff2fff2ff22110665051aaa
32f777100d60d0ee7727703333333322222f2800002f1cc111133333bbbbb0800000bbb32288aaaaaaaaaaaaaaaaaaaa1502888222282ff222111666060151aa
3277471010dd1000001c7113333333326f22e2e8222ee1cc11333333bbb0000088880bbaaaaaaaaaaaaaaaaaaaaaaaaa1560228882282fff20166611106551aa
2f4f4f000111d011ccc11c113333332ed7d828882ee8766d82333333bbb08808888880baaaaaaaaaaaaaaaaaaaaaaaaa0560112222222fff25611111106550aa
2ff42ff00101000112f1cc12333332eee7222222d2877227e2333333bb088888888880baaaaaaaaaaaaaaaaaaaaaaaaa0561111112222fff22011111116150aa
22222f0080000f8112feeee23333268e888820062287e888e2233333bb08888080880bbaaaaaaaaaaaaaaaaaaaaaaaaa5561111111122ff222011111116155aa
3333327767d62e82e8e7776223332767662033302ee8888826233333000888080080000aaaaaaaaaaaaaaaaaaaaaaaaa556011111112222882111111106155aa
333332ee277288822ee77777e223222222233330622888876233333308088000800880baaaaaaaaaaaaaaaaaaaaaaaaa556011111100228882001111106155aa
333332ee82882d6622877eeeee6233333333333306676766233333330888880080000bbaaaaaaaaaaaaaaaaaaaaaaaaa555601110000228820000011061555aa
333332782222d200308ee88882723333333333333222222233333333b00808888880bbbaaaaaaaaaaaaaaaaaaaaaaaaa555566600000028200000006615555aa
3333332776720033302ee8882762aaaaaaaaaaaaaaaaaaaaaaaaaaaab0880000000bbbbaaaaaaaaaaaaaaaaaaaaaaaaa555551166666662266666661555555aa
3333333222223333306677776623aaaaaaaaaaaaaaaaaaaaaaaaaaaab000bbbbbbbbbbbaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
3333333333333333330022222233aaaaaaaaaaaaaaaa2222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2442aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa222a22222222aaaaaaaaaaaaaaaa222aa222aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa2aaaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaa2aaaaaaaaaaaaaaaaaaaaaaa244442224444442aaaaaaaaaaaaaaaa222244422aaaaaaaaaaaaaaaaaaaaaaaaaa2222a22aaaaaaaaaaaaaaaa
aaaaaaaaaaaaaaa22aaaaaaaaaaaaaaaaaaaaa24444444444444442aaaaaaaaaaaaaaa4244444442aaaaaaaaaaaaaaaaaaaaaaa2444442242aaaaaaaaaaaaaaa
aaaaaaaaaaa22224424222aaaaaaaaaaaa2aa2ff4444ff44f4444ff2aaaaaaaaaaa42224444444ff2aaaaaaaaaaaaaaaaaaaaa2f4444442244222aaaaaaaaaaa
aaaaaaaaa244444224444442aaaaaaaaa2aaa2fffffff4fffffffff2aaaaaaaaa24444444444ff4442aaaaaaaaaaaaaaaa22a2ff44444444444442aaaaaaaaaa
aaaaaaaa24444444444444442aaaaaaaa22a2f4444f4f4ff4ff444442aaaaaaa244444f44ffff44442aaaaaaaaaaaaaaaa2aa2ffffffff444444442aaaaaaaaa
aaaaaaaaff4444fff4fffffff2aaaaaaa2424444444444444444444442aaaaa444444ffff4ff4444442aaaaaaaaaaaaaa244222444f4fff4f44444faaaaaaaaa
aaaaaaa2ffffffffffffff44442aaaaaa2444244444444444444444442aaaaa2fffff4f4f4444444444aaaaaaaaaaaaaa24424444444f4fffffffff2aaaaaaaa
aaaa2a2f444444ff4f4f4444444aaaaaa2444244424424224444444442aaaaa2fffff4f444444444424aaaaaaaaaaaaaa2424444444444f44ff444f2aaaaaaaa
aaaa42424444444444444444444aaaaaaa2442442e0442e02444444442aaaaa24444444444444444424aaaaaaaaaaaaaa242444222444444444444442aaaaaaa
aaaa444444424444444444444442aaaaaaa24242e4000200024444424aaa2aa44444244242444444442aaaaaaaaaaaaaaa24422ee2424224444444442aaaaaaa
aaaa2444442e4424224444444242aaaaaaa242424f00ef0000242e442aaa22244442e2422e224444244222aaaaaaaaaaaa222e0efe222e24444444442aaaaaaa
aaaa244442ee2422ee2444444242aaaaaa244422ff44fff44e242e4442a22444442ee022e0002442f44442aaaaaaaaaaa24420f000ee0002444444442aaaaaaa
aaaaa244214000e000024442442aaaaaaa22440effffffffff224244422aa2442424000ee000e242e4422aaaaaaaaaaaa242ffffff0ee002244444242aaaaaaa
aaaaa24222ff00ff000e242e24422aaaaaa2440ff22f22f22f44442222aaaa24242ef44fff44f242222442aaaaaaaaaaa242ffffffffe00024224422aaaaaaaa
aaaaaa4442ff44ff44fe242e4422aaaaaaa444402f2ff82f2224444442aaaaa2242fff4ff22ff222444442aaaaaaaaaaa2240ffff220f44242ef242aaaaaaaaa
aaaaa2442fffff220fff442422aa2aaaaa244442ff28882f244444442aaaaaa242effff2222f2244444442aaaaaaaaaa2444400fff88fff242e2442aaaaaaaaa
aaaaa2440ffffff88ff2244442222aaaaa244442ff28882ff2444442aaaaaaa240ffffffff22ef2444422aaaaaaaaaa2444444422228262442244442aaaaaaaa
aaaaa24440022222222f22444442aaaaaa4444222f2282222244444aaaaaaaa2240002222288ff2444442aaaaaaaaaa2444444428882822424422222aaaaaaaa
aaaaa44442f2888882ff2444444aaaa2224442ffef2202e2ef244442aaaaaa2ff22228822222ef24444442aaaaaaa22444444442222222e2222fe22aaaaaaaaa
aaaa244422228822822f2444442aaaaa244442ee2f2220ee2e244242aaaaaaa2effff2228fff2e24442242aaaaaaa2444444442eff82222effe222aaaaaaaaaa
aaaa24442ef220222ee2244442aaaaaaa2222422ee2222222e244a22aaaaaaaa22e2f22222fff244442a42aaaaaaaa222444442ff22222222f242aaaaaaaaaaa
aaaa2442fffe2002effe2444442aaaaaaaaa242e22efffe242244a2aaaaaaaaa2fee220002eff2444442a2aaaaaaaaaaa2444422fe200222ee22aaaaaaaaaaaa
aa224442efff2222fffe2442442aaaaaaaa224422efffffe24442aaaaaaaaaaaa2e2e2efff2e22244442aaaaaaaaaaaa2444442222efff222242aaaaaaaaaaaa
aaa244242eff2ff2ff2224422a2aaaaaaaaaa242ef222ffff242aaaaaaaaaaaa242222f22ff22e24442aaaaaaaaaaaaa222442eefffffff2e2442aaaaaaaaaaa
aaa1111122ff2222ff221111111aaaaaa1111112f2fff2fff21111111aaaaaa11112ee2ff2eeee211111111aaaaaa111111112effffffff221111aaaaaaaaaaa
a1155556628f2ff28f26666655511aa11555622ff2ffe2ffe2666555511aa115552ff2ffff2ee266666655511aa1155566662eff2224ff266555511aaaaaaaaa
a105566022ee2ef2ee21110066051aa105222efff2fee22221110665051aa10522fff2feef222111110066051aa105660224eff2fff222110665051aaaaaaaaa
15016022e2222ef2221116661061511502888222e2fff21111166606015115028eff52feef2111111666106151150601222fff02fee2111666060151aaaaaaaa
155622effe22fff2111166111106511560288880812ff22016661110655115288882222fff221111661111065115600288882222fee4266611106551aaaaaaaa
0552288882212ff2201611111106500560122228802efe826111111065500522222222122ff2201611111106500560112222222222ff221111106550aaaaaaaa
0512222222202fff2201111111065005611111111028ff820111111161500516111122122ff2250111111106500561111111122522ff221111116150aaaaaaaa
55161111222022ff2201111111065555611111111028ff820111111161555516111111128ff8250111111106555561111111105522ff821111116155aaaaaaaa
55161111111122ff82111111110655556011111111028882111111106155551611111111288820111111110655556011111111000288821111106155aaaaaaaa
555161110000028882000011106155556011111100002882001111106155555161110000028820000011106155556011111100000028821111106155aaaaaaaa
555516000000002882000000061555555601110000000220000011061555555516000000002220000000061555555601110000000002200011061555aaaaaaaa
555551666000000220000066615555555566600000000000000006615555555551666000000000000066615555555566600000000000000006615555aaaaaaaa
555555551666666666666615555555555551166666666666666661555555555555551666666666666615555555555551166666666666666661555555aaaaaaaa
__label__
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
99999999955999999999955555599999999955559999999999559999999999999999999999995599999999995555559999999995555999999999955999999999
99999995566599999999956666599999999566665999999995665599999999999999999999556659999999995666659999999956666599999999566559999999
99999956666599999999956666599999995666666599999995666659999999999999999995666659999f99995666659999999566666659999999566665999999
9999956666555559999555666655599995666666665999555556666599999999999999995666655555f9ff555666655599995666666665999555556666599999
99995666666666599956656666566599956666666659995666666666599999999999999566666666659995665666656659995666666665999566666666659999
99995666666666599956666666666599566666666665995666666666599999999999999566666666659995666666666659956666666666599566666666659999
99995666666666599995666666665999566566665665995666666666599999999999999566666666659999566666666599956656666566599566666666659999
99995666666666599995666666665999955566665559995666666666599999999999999566666666659999566666666599995556666555999566666666659999
99999566665555599999566666659999999566665999995555566665999999999999999956666555559999956666665999999956666599999555556666599999
9999995666659999999995666659999999956666599999999566665999999999999999999566665999999999566665ff99999956666599999999566665999999
99999995566599999999995555999999999555555999999995665599999999999999999fff5566599999999995555999f9999955555599999999566559999999
99999999955999999999999999999999999999999999999999559999999999999999fff99999559999999999999999999ff99999999999999999955999999999
999999999999999999999999999999999999999999999999999999999999999999ff9999999999999999999999999999999ff999999999999999999999999999
999999999999999999999999999999999999999999999999999999999999999fff99999999999999999999999999999999999ff9999999999999999999999999
999999999999999999999999999999fff999999999999999999999999999fff9999999999999999999999999999999999999999ff99999999999999999999999
99999999999999999999999999ffff999ff9999999999999999999999fff999999999999999999999999999999999999999999999ff999999999999999999999
9999999999999999999999ffff999999999ff99999999999999999fff99999999999999999999999999999999999999999999999999ff9999999999999999999
999999999999999999ffff999999999999999f99999999999999ff9999999999999999999999999999999999999999999999999999999ff99999999999999999
99999999999999ffff99999999999999999999ff999999999fff99999999999999999999999999999999999999999999999999999999999ffff9999999999999
999999999fffff99999999999999999999999999ff9999fff999999999999999999999999999999999999999999999999999999999999999999ffff999999999
99999ffff999999999999999999999999999999999ffff9999999999999999999999999999999999999999999999999999999999999999999999999ffff99999
9ffff9999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999999999999999999fffff
f9999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999fffff99999999999999999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999999999fffff999999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999999fffff9999999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999999999999999999fff9999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999222299999999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999999924222299999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999999222222444442999999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999924444444444f44299999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999999244444444f44f44499999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999999994ff44ff44fff444429999999999999999999999999999999999999999999999999999999
999999999999999999999999999999999999999999999999999992994444f4f4f444444429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999292244444444444444429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999442444444444444444229999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999924242224442ff244ff429999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999922222f24f220f227f242299999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992222f00ff402f272222999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992242ff0f77474222249999999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999992442f74777774424442929999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999942f777208272244444429999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999940f777788774244444299999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999929444002222222f724444299999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999922444448eeeee477f4444429999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999244444f08828824774444429999999999999999999999999999999999999999999999999999
99999999999999999999999999999999999999999999999999999924444f00000822774444229999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999444f2f7774400f72442999999999999999999999999999999999999999999999999999999
9999999999999999999999999999999999999999999999999999999247727777777f077f22999999999999999999999999999999999999999999999999999999
99999999999999999999900000000000999999999999999999999111f742f7222f770f7227211999999999999999999999999999999999999999999999999999
99999999999999999990000000000000099999999999999999911555552f727772ff466665555119999999999999999999999999999999999999999999999999
999999999999999999000000000000000999999999999999999105562277727ff221111106650519999999999999999999999999999999999999999999999999
9999999999999999990000006777777600999999999999999915012277772277f211111666060159999999999999999999999999999999999999999999999999
999999999999999999000677777777777609999999999999991562eee82282f77000166611106559999999999999999999999999999999999999999999999999
99999999999999999000677777777777770999999999999999056022ee20202f7255611111106559999999999999999999999999999999999999999999999999
99999999999999999000777777777777770999999999999999056111221110227f82011111116159999999999999999999999999999999999999999999999999
999999999999999990007777777777777709999999999999995561111111102877e2011111116159999999999999999999999999999999999999999999999999
9999999999999999900077777777777777099999999999999955601111111102e7e2111111106159999999999999999999999999999999999999999999999999
99999999999999999000677777777777760999999999911100556011111100002ee2001111106150011199999999999999222222222999999999999999999999
99999999999999999000067776000677600999999911155560555601110000000222000011061550655511199999999922eeeeeee28099999999999999999999
9999999999999999900000000006000000999999115000556155556660000000000000000661555165500051199999992eeeeeee288809999999999999999999
999999999999999999000006600006600990707156011505615555511666666666666666615555516505110651999992eeee6eee288809999999999999999999
999999999999999999000007077707000900060750115505615555556600000001100000665555516505511051999990cee16ee2888880999999999999999999
9999999999999999999000000000000009060660501161056155556601111111111111166066555165016110519999066606cee2888880999999999999999999
9999999999999999997700060000060000d0606056110005515556001111111111111166110065515500011651444166c666c0e2088880999999999999999999
9999999999999999900600077666770000d0d000056005555155560111111100000016111110655155550065514416cc0cc6cce0888882200999999999999999
9999999999944004760000077777776010d00105055500055105561111111055555501111111655155000555514416cc0ccccc6000080771c444999999999999
999944444444000006004407777777701000566005601110510116111111105555550111111161115011106550004116c01fff0f6cc1f2f01444444444499999
4444444444440000000011677777776011010000100111505101160111111055555501111110611150511105016d046c1f0ff20ff11cf2244444444444444444
4444444444440000000010167777760401011001010116505101160111111100000011111110611150561100dd16d0c12ff02f47fff222444444444444444444
44444444444400000000000100000004011111000101100051011560110000000000000011065111500011000dd00012f774777f772244444444444444444444
4444444444444000000000010000000100010000016011001040115660000000000000000665110010011060d0d16022777f77f7727624444444444444444444
444444444444400000000111000000000000111014444444444011155666000000000066655111044444444401610722f777ff72267724444444444444444444
44444444444444000000010100000000010041114444444444444444444444444444444444444444444444444000757422222886666772444444444444444444
444444444444444000000001044440001014444444444444444444444444444444444444444444444444444442f772f26666e66e720222444444444444444444
4444444444444444000001100044000000044444444444444444444444444444444444444444444444444444427777726077e7ee72ff44444444444444444444
444444444444444440011100004400000001444444444444444444444444444444444444444444444444444442ff7740cc077ee702fff4444444444444444444
4444444444444444400000000144000000014444444444444444444444444444444444444444444444444444442fff771110111cc177fc444444444444444444
444444444444444440000000014000000001444444444444444444444444444444444444444444444444444444224fffff2111cccc1111444444444444444444
44444444444444441000000001400000000144444444444444444444444444444444444444444444444444444444222eeef00102f1cc12444444444444444444
4444444444444444100000000140000000014444444444444444444444444444444444444444444444444444444444267ee2f212feeee2444444444444444444
44444444444444441110000011400000011011444444444444444444444444444444444444444444444444444444277767288ee8e77724444444444444444444
44444444444444400001000001400000000001444444444444444444444444444444444444444444444444444442ee27728882ee777772244444444444444444
44444444444444000000000001440000000001444444444444444444444444444444444444444444444444444442ee82882e62287eeeee824444444444444444
44444444444444000000000114444000000011444444444444444444444444444444444444444444444444444427882222e0008ee88888224444444444444444
4444444444444400000001144444444400111444444444444444444444444444444444444444444444444444442776776244402ee88882624444444444444444
44444444444444411111144444444444444444444444444444444444444444444444444444444444444444444442222224444066777776244444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444400000000444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444000000000044444444411114444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
4444444400000000000442333311ccc1113333333333333333333333333333333333333333333333333333333333333333333333334444444444444444444444
44444440000000000004488bb1c1cccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007777777004488b1ccc1ccc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007777777004488b11cc11111c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444440007770777004488bb1c11c1c11111bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
44444444000007000044488bb11c1c11cc1c1bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb34444444444444444444444
4444444440070077004442333131cccc1c1133333333333333333333333333333333333333333333333333333333333333333333334444444444444444444444
44444444444444444444444444441111111444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444

__sfx__
2d0200200407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073
000200000f860200201b0101b0301b020150100b01006010030200002022000260002100019000110000e0000a000080000800006000040000400004000030000100000000010000000000000000000000000000
010200200407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073040730407304073
010100001c3501e3502035022350233502635027350293502b3502c3502a35026350203501c350143500e350083500635004350033500435006350073500a3500e35011350103500c35004350023500135002350
011200000c073000030c600000000c673000030c0000c6230c0730c6230c600000030c6730000311600000030c073000030c600000000c673000030c0000c6230c0730c6230c000000030c673000030560000003
010100200055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552005520055200552
010400000c07300073180701807018070180701807018070180701807018070180701807018070180701807018070180701807018070180701807018070180701807018070180701807018070180701807018070
010400000c07300073000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070000700007000070
011200002874024700287402470024740247002874024740247002474030700287402474024700217403070028740247002874024700247402470028740247402470024740307002874024740247002174030700
2b0c00000050000500005000050000500005001e5300c5001c530185001e5301850018500185001e5301850018500185001e5301850018500185001e530185001c530185001e5301850018500185001253012535
010c00000c073000030c623000000c673000030c073000030c623000000c623000030c6730000311600000030c073000030c623000000c673000030c073000030c653000000c0000c6530c600000030c65300003
010c000012f7012f700c62300000306250000300000186150c6230c61312f7012f703c62500003116003062512f7012f700c62300000306250000300000186150c6230c6130c623000033c625000031160030625
010c000012f7012f700c62300000306250000300000186150c6230c61312f7012f703c62500003116003062512f7012f700c62300000306250000300000186151ef701ef701ef701ef701cf701cf701af701af70
011200000c073000030c600000000c673000030c0000c6230c0730c6230c600000030c6730000311600000030c073000030c600000000c673000030c0000c6230c0730c6230c000000030c673000030c6730c673
011200000a07000000000000a07000000000000a0700c070000000c0700c0000c0700c0000c0000c070050700c000050700000005070000000000005070050700000005070000000507000000050700507000000
2b120000247522475224700187001870018700187001870029752297521e7001870018700187001e7001870024752247521e7001870018700187001e7001870029752297521e7001870018700187001270012700
2b1200002d5522d55224500185001850018500185001850024552245521e5001850018500185001e500185002d5522d5521e5001850018500185001e5001850024552245521e5001850018500185001250012500
2b12000029700000002970029700247002d70018700187001870029700297001e7001870018700187001e7001870024700247001e7001870018700187001e70029742000002974529742247652d7421870018700
b50c000000502005020657200502065720050206572005020657200502065720000006572000000656200000065720000006575065750657200000065720000017d6217d6217d6217d6517d6217d6217d6217d65
b50c000000502005020657200502065720050206572005020657200502065720000006572000000656200000065720000006572065000657200000065720000017d6217d6217d6217d6517d6217d6217d6217d65
bb0c000000502005021e572185021e572185021e572185021e572185021e572180001e572180001e562180001e572180001e5751e5751e572180001e572180001756217562175621756517562175621756217565
2b12000029752297522470018700187001870018700187002b7522b7521e7001870018700187001e7001870029752297521e7001870018700187001e700187002b7522b7521e7001870018700187001270012700
010c000012f5012f5012f5012f5012f5012f5012f5012f5017f5017f5017f5017f5017f5017f5017f5017f501ef501ef501ef501ef501ef501ef501ef501ef5017f5017f5017f5017f5017f5017f5017f5017f50
010c000012f7012f700c62300000306250000300000186150c6230c61312f7012f703c62500003116003062512f7012f700c6230c623306250c6230c62318615306250c600000033062500003116003062500000
390c00001e5141e5101e5101e5101e5101e5101e5101e515175141751017510175101751017510175101751519514195101951019510195101951019510195151c5141c5101c5101c5101c5101c5101c5101c515
2b12000029552295522450018500185001850018500185002b5522b5521e5001850018500185001e5001850029552295521e5001850018500185001e500185002b5522b5521e5001850018500185001250012500
2b1200002d7522d75224700187001870018700187001870029752297521e7001870018700187001e700187002b7522b7521e7001870018700187001e7001870024752247521e7001870018700187001270012700
2b1200002d5522d55224500185001850018500185001850029552295521e5001850018500185001e500185002b5522b5521e5001850018500185001e5001850024552245521e5001850018500185001250012500
2b12000024752247520000000000247522475218700187002875228752000001870029700297001e7001870024752247520000000000247522475218700187001d7521d752000001870029700297001e70018700
2b1200002b5522b55224500185002b5522b552185001850029552295521e5001850018500185001e500185002b5522b5521e500185002b5522b5521e5001850024552245521e5001850018500185001250012500
2b12000029752297522d7523000024752247522975218700187000000000000000002475224752000001870029552295522d55230500245522455229552185001850000500005000050024552245520050018500
2b1200002255222552000000000021552215522d700300001f5521f55229700187001d5521d55200000000002e5522e55200000187002d5522d5522d500305002b5522b55229500185002d5522d5520050000500
2b1200001d5521d5521d5521d5521d5421d5421d5421d5421d5321d5321d5321d5321d5221d5221d5221d5222e5002e50000000187002d5002d5002d500305002b5002b50029500185002d5002d5000050000500
011200000c073000031861300000186230000018613000000c673000031861300000186230000018613000030c073000031861300000186230000018613000000c67300003186130000018623000001861300003
011200000c0730000318613000000c6730000018613000000c0730000318613000000c6730000018613000030c0730000318613000000c6730000018613000030c0730000318613000000c673000001861300003
011200000a07000000000000a07000000000000c0750c070000000c0700c0000c0700c0000c0000c070050700c000050700000005070000000000005070050700000005070000000507000000050700507000000
01120000110521105215052150520c0520c0521105211052110521105211052110520c0520c0520c0520c052110521105215052150520c0520c0521105211052110521105211052110520c0520c0520c0520c052
011200000a0520a0520a0520a05209052090520905209052070520705207052070520505205052050520505216052160521605216052150521505215052150521305213052130521305215052150521505215052
011200000505205052050520505205052050520505205052050420504205042050420504205042050420504205032050320503205032050320503205032050320502205022050220502205022050220502205022
011200001174015740187401c7401174015740187401c7401173015730187301c7301173015730187301c7301172015720187201c7201172015720187201c7201171015710187101c7101171015710187101c710
000900001d0001d0001e0001e0001d0001d0001d0001d0001d0001d0001d0001d0001d0001c0001900019000190001a0001a0001a000000000000000000000000000000000000000000000000000000000000000
__music__
00 04084344
00 0d084344
00 04480e0f
00 0d110e10
00 04480e15
00 0d110e19
00 04480e1a
00 0d510e1b
00 2148231c
00 2151231d
00 2251231e
00 2251251f
00 0d272620
00 28424344

